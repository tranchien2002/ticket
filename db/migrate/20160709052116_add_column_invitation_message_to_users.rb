class AddColumnInvitationMessageToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :invitation_message, :text
  end
end
