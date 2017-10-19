class CreateDocs < ActiveRecord::Migration[5.1]
  def change
    create_table :docs do |t|
      t.string :title
      t.text :body
      t.string :keywords
      t.string :title_tag
      t.string :meta_description
      t.integer :category_id
      t.boolean :active, :default => true
      t.integer :rank
      t.string :permalink
      t.integer :version
      t.boolean :front_page, :default => false
      t.boolean :cheatsheet, :default => false
      t.integer :points, :default => 0
      t.string  :attachments, array: true, default: "[]"

      t.references :user, foreign_key: true
      t.timestamps null: false
    end
  end
end
