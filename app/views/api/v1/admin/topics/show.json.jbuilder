json.code 1
json.message "Thành công"
json.data do
  json.topic do
    json.merge! @topic.attributes
    json.user do
      json.uid @topic.user.try(:uid).to_i
      json.name @topic.user.try(:name)
      json.email @topic.user.try(:email)
      json.avatar @topic.user.try(:avatar)
    end
    json.assigned_user do
      json.uid @topic.assigned_user.try(:uid).to_i
      json.name @topic.assigned_user.try(:name)
      json.email @topic.assigned_user.try(:email)
      json.avatar @topic.assigned_user.try(:avatar)
      json.type @topic.assigned_user.try(:role)
    end
  end
  json.posts @posts.each do |post|
    json.merge! post.attributes
    json.attachments JSON.parse(post.attachments) rescue []
  end
end
