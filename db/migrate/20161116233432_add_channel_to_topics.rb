class AddChannelToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :channel, :string, default: 'email'
  end
end
