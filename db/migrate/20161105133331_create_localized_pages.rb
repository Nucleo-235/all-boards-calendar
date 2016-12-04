class CreateLocalizedPages < ActiveRecord::Migration
  def change
    create_table :localized_pages do |t|
      t.string :locale

      t.timestamps null: false
    end
  end
end
