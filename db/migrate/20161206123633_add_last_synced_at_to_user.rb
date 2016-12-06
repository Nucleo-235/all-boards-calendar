class AddLastSyncedAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_synced_at, :datetime
  end
end
