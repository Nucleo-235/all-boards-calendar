class CreateLocalizedValues < ActiveRecord::Migration
  def change
    create_table :localized_values do |t|
      t.references :localized_page, index: true, foreign_key: true
      t.string :key
      t.text :value

      t.timestamps null: false
    end
  end
end
