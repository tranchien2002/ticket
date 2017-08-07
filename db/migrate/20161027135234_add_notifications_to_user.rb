class AddNotificationsToUser < ActiveRecord::Migration[5.1][5.1]
  def change
    change_table :users do |t|
      t.boolean   :notify_on_private, default: false
      t.boolean   :notify_on_public, default: false
      t.boolean   :notify_on_reply, default: false
      t.index     :notify_on_private
      t.index     :notify_on_public
      t.index     :notify_on_reply
    end
  end
end
