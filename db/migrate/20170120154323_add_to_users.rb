class AddToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :priority, :string, default: 'normal'
    add_index :users, :priority
  end
end
