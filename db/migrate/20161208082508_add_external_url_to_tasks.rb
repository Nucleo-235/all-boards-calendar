class AddExternalUrlToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :external_url, :string
  end
end
