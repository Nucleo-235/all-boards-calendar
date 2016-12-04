class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :type
      t.string :name, null: false
      t.string :slug
      t.references :user, index: true, foreign_key: true
      t.text :description
      t.string :documentation_url
      t.string :code_url
      t.string :assets_url

      t.timestamps null: false
    end

    add_index :projects, :slug, unique: true
  end
end
