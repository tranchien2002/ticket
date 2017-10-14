class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :label
      t.string :name
      t.string :content
      t.integer :parent_id, index: true
      t.integer :lft, null: false, index: true, default: 0
      t.integer :rgt, null: false, index: true, default: 0
      t.integer :buiding_id, index: true, null: false

      t.timestamps
    end
  end
end
