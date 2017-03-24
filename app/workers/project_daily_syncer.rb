class ProjectDailySyncer
  include Sidekiq::Worker

  def perform()
    puts "Sidekiq for ProjectDailySyncer STARTING"
    Rails.application.routes.default_url_options[:host] = (ENV["HOST_URL"] || 'localhost:3000')
    
    # Cria o cron worker novamente para o dia de amanha
    ProjectDailySyncer.start

    diff = 30.seconds
    delay = 0
    User.where('last_synced_at > ?', Time.new.beginning_of_day).each do |user|
      if user.trello_client
        delay = delay + diff
        ProjectDailySyncer.delay_for(delay).sync_user(user.id)
      end
    end

    puts "Sidekiq for ProjectDailySyncer FINISHED"
  end

  def self.sync_user(user_id)
    user = User.find(user_id)
    if user.trello_client
      # synca mudanças
      newSyncDate = Time.new

      if user.last_synced_at || user.projects.where.not(last_synced_at: nil).length > 0
        member_id = user.trello_member.id
        user.trello_changed_cards(user.last_synced_at, newSyncDate).each do |changed_card|
          begin
            project_info = TrelloProjectInfo.find_by(board_id: changed_card.board_id)
            if project_info
              TrelloTask.sync_task(changed_card, project_info.project, member_id)
            end
          rescue
            puts changed_card.to_json
            raise
          end
        end

        user.last_synced_at = newSyncDate
        user.save!
      end
    end
  end

  def self.start
    set = Sidekiq::ScheduledSet.new
    jobs = set.select {|job| job.klass == 'ProjectDailySyncer' }
    if jobs.length == 0
      interval = 60.minutes
      ProjectDailySyncer.perform_in(interval)
    end
  end
end