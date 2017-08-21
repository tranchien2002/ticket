json.code 1
json.message "Thành công"
json.data do
  json.topics @topics.each do |topic|
    json.merge! topic.attributes.except("user_name", "user_email", "assigned_user_name", "assigned_user_email")
    json.user do
      json.name topic.user_name
      json.email topic.user_email
    end
    json.assigned_user do
      json.name topic.assigned_user_name
      json.email topic.assigned_user_email
    end
  end
  json.status @status
  json.box do
    json.new @new
    json.pending @pending
    json.open @open
    json.active @active
    json.mine @mine
    json.closed @closed
  end
  json.extra_info do
    json.unread @unread
    json.spam @spam
  end
  json.page params[:page]
  json.per_page Settings.per_page
  json.total_items @topics.total_entries
end
