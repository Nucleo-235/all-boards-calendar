class AddCalendarCodesToUser < ActiveRecord::Migration
  def change
    add_column :users, :calendar_code, :string
    add_column :users, :calendar_public_code, :string
    add_column :users, :all_day_calendar_code, :string
    add_column :users, :all_day_calendar_public_code, :string
    add_column :users, :hour_calendar_code, :string
    add_column :users, :hour_calendar_public_code, :string
  end
end
