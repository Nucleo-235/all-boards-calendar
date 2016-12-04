class ProjectSyncer
  include Sidekiq::Worker

  def perform()
    puts "Sidekiq for ProjectSyncer STARTING"
    Rails.application.routes.default_url_options[:host] = (ENV["HOST_URL"] || 'localhost:3000')
    
    # Cria o cron worker novamente para o dia de amanha
    ProjectSyncer.start

    Project.all.each do |project|
      Project.delay.sync_project(project.id)
    end

    User.all.each do |user|
      if user.trello_client
        user.trello_open_boards.each do |board|
          if TrelloProjectInfo.where(board_id: board.id).length == 0
            project = TrelloProject.new({name: board.name, description: board.description, info_attributes: {board_id: board.id}})
            project.user = user
            project.save!
          end
        end
      end
    end

    puts "Sidekiq for ProjectSyncer FINISHED"
  end

  def self.start
    set = Sidekiq::ScheduledSet.new
    jobs = set.select {|job| job.klass == 'ProjectSyncer' }
    if jobs.length == 0
      interval = 1.day
      ProjectSyncer.perform_in(interval)
    end
  end
end