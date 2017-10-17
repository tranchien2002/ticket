class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.integer :points, :default => 1
      t.string :voteable_type
      t.integer :voteable_id


      t.references :user,:default => 0, foreign_key: true
      t.timestamps null: false
    end
  end
end
