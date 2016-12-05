class AddLastSyncedAtToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :last_synced_at, :datetime
  end
end
