class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.references :user, index: true, foreign_key: true
      t.text :excluded_labels

      t.timestamps null: false
    end
  end
end
