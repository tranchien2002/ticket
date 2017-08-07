class AddLangToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :locale, :string#, default: 'en'
  end
end
