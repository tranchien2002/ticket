class AddLocaleToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :versions, :locale, :string
  end
end
