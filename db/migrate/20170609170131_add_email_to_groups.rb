class AddEmailToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :email_address, :string
    add_column :tags, :email_name, :string
  end
end
