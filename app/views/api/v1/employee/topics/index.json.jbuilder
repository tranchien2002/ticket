json.code 1
json.message "Thành công"
json.data do
  json.topics @topics.each do |topic|
    json.merge! topic.attributes.except("user_name", "user_email", "assigned_user_name", "assigned_user_email")
    json.user do
      json.uid topic.user_uid.to_i
      json.name topic.user_name
      json.email topic.user_email
    end
    json.assigned_user do
      json.uid topic.assigned_user_uid.to_i
      json.name topic.assigned_user_name
      json.email topic.assigned_user_email
    end
  end
  json.status @status
  json.page params[:page].to_i
  json.per_page Settings.per_page
  json.total_items @topics.total_entries
end
