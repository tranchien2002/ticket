class AddAccountNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :account_number, :string
  end
end
