class AddCcToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :cc, :string
    add_column :posts, :bcc, :string
  end
end
