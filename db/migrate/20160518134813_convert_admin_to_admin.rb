class ConvertAdminToAdmin < ActiveRecord::Migration[5.1]
  def change
    # Iterate through users and give them an admin role if they have the flag
    User.admins.each do |admin|
      admin.update_attribute(:role, 'admin') if admin.admin?
    end
  end
end
