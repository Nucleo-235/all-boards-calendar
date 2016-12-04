class AddTrelloListIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :trello_list_id, :string
  end
end
