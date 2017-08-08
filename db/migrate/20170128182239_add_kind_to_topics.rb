class AddKindToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :kind, :string, default: 'ticket'
    add_index :topics, :kind
  end
end
