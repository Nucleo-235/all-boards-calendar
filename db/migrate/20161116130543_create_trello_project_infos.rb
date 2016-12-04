class CreateTrelloProjectInfos < ActiveRecord::Migration
  def change
    create_table :trello_project_infos do |t|
      t.references :project, index: true, foreign_key: true, unique: true
      t.string :board_id
      t.string :todo_list_id

      t.timestamps null: false
    end
  end
end
