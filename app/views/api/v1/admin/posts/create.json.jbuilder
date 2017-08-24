json.code 1
json.message "Thành công"
json.data do
  json.merge! @post.attributes
  json.user_name @current_user.name
  json.user_email @current_user.email
  json.user_avatar @current_user.avatar
  json.attachments JSON.parse(@post.attachments) rescue []
end
