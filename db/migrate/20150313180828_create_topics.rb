class CreateTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :topics do |t|
      t.integer :forum_id
      # t.integer :user_id
      t.string :name
      t.integer :posts_count, :default => 0, :null => false
      t.string :waiting_on, :default => 'admin', :null => false
      t.datetime :last_post_date
      t.datetime :closed_date
      t.integer :last_post_id
      t.string :current_status, :default => "new", :null => false
      t.boolean :private, :default => false
      t.integer :assigned_user_id
      t.boolean :cheatsheet, :default => false
      t.integer :points, :default => 0
      t.text :post_cache
      t.datetime :begin_date, :default => Time.zone.now
      t.datetime :deadline
      t.string :locale #, default: 'en'
      t.string :channel, default: 'email'
      t.string :kind, default: 'ticket'


      t.integer :building_id
      t.references :user, foreign_key: true
      t.timestamps null: false
    end
    add_index :topics, :kind
  end
end
