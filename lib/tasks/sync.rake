namespace :sync do
  task all_projects: :environment do
    Rails.application.routes.default_url_options[:host] = (ENV["HOST_URL"] || 'localhost:3000')
    
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
  end
end
