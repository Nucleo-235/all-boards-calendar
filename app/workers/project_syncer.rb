class ProjectSyncer
  include Sidekiq::Worker

  def perform()
    puts "Sidekiq for ProjectSyncer STARTING"
    Rails.application.routes.default_url_options[:host] = (ENV["HOST_URL"] || 'localhost:3000')
    
    # Cria o cron worker novamente para o dia de amanha
    ProjectSyncer.start

    diff = 30.seconds
    delay = 0
    User.all.each do |user|
      if user.trello_client
        delay = delay + diff
        ProjectSyncer.delay_for(delay).sync_user(user.id)
      end
    end

    puts "Sidekiq for ProjectSyncer FINISHED"
  end

  def self.sync_user(user_id)
    user = User.find(user_id)
    if user.trello_client
      # sync boards
      user.trello_open_boards.each do |board|
        TrelloProject.update_or_create(board, user)
      end

      task_min_date = TrelloTask.joins(:project).where(projects: { user_id: user.id }).minimum(:last_synced_at)
      task_min_date = TrelloProject.where(user_id: user.id ).minimum(:last_synced_at) if !task_min_date
      user.trello_changed_cards(task_min_date).each do |changed_card|
        project_info = TrelloProjectInfo.find_by(board_id: changed_card.board_id)
        if project_info
          TrelloTask.sync_task(changed_card, project_info.project)
        end
      end
    end
  end

  def self.start
    set = Sidekiq::ScheduledSet.new
    jobs = set.select {|job| job.klass == 'ProjectSyncer' }
    if jobs.length == 0
      interval = 3.hours
      ProjectSyncer.perform_in(interval)
    end
  end
end