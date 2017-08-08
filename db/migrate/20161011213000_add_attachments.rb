class AddAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :attachments, :string, array: true, default: [].to_yaml
    add_column :docs, :attachments, :string, array: true, default: [].to_yaml
    add_column :users, :profile_image, :string
  end
end
