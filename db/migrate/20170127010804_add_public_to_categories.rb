class AddPublicToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :visibility, :string, default: 'all'
  end
end
