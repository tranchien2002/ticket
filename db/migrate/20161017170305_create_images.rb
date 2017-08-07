class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :key
      t.string :name
      t.string :extension
      t.text :file

      t.timestamps null: false
    end
  end
end
