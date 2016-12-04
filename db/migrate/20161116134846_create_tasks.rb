class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :project, index: true, foreign_key: true
      t.string :type
      t.string :name
      t.text :description
      t.datetime :due_date
      t.boolean :completed, default: false
      t.boolean :assigned, default: false
      t.integer :sort_order
      t.string :trello_card_id

      t.timestamps null: false
    end
  end
end
