class AddColumnsToTag < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :show_on_helpcenter, :boolean, :default => false
    add_column :tags, :show_on_admin, :boolean, :default => false
    add_column :tags, :show_on_dashboard, :boolean, :default => false
  end
end
