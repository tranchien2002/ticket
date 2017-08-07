class AddRawToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :raw_email, :text
  end
end
