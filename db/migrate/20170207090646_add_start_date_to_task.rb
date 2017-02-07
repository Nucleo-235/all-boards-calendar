class AddStartDateToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :start_date, :datetime
    add_column :tasks, :all_day, :boolean
  end
end
