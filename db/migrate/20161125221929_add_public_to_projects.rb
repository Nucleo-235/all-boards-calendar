class AddPublicToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :public, :boolean, default: true
  end
end
