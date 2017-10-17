class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.integer :topic_id
      t.text :body
      t.string :kind #reply or first, note
      t.boolean :active, :default => true
      t.string :cc
      t.string :bcc
      t.text :raw_email
      t.string :attachments,  array: true, default: "[]"

      t.references :topic, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps null: false
    end
  end
end
