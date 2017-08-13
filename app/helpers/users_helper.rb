module UsersHelper

  # def user_avatar(user, size=40)
  #   if user.thumbnail == "" && user.avatar.nil?
  #     user.gravatar_url(:size => 60)
  #   elsif user.avatar.nil? == false
  #     "https://res.cloudinary.com/helpy-io/image/upload/c_thumb,w_#{size},h_#{size}/#{user.avatar.path}"
  #   else
  #     user.thumbnail
  #   end
  # end

  # def avatar_image(user, size=40, font=16)
  #   return if user.nil?
  #   if user.avatar.present?
  #     unless Cloudinary.config.cloud_name.nil?
  #       image_tag("https://res.cloudinary.com/#{Cloudinary.config.cloud_name}/image/upload/c_thumb,w_#{size},h_#{size}/#{user.avatar.path}", width: "#{size}px", class: 'img-circle')
  #     else
  #       image_tag('', data: { name: "#{user.name}", width: "#{size}", height: "#{size}", 'font-size' => font, 'char-count' => 2}, class: 'profile img-circle')
  #     end
  #   elsif user.profile_image.present?
  #     image_tag(user.profile_image.url, width: "#{size}px", class: 'img-circle')
  #   elsif user.thumbnail.present?
  #     image_tag(user.thumbnail, width: "#{size}px", class: 'img-circle')
  #   else
  #     image_tag('', data: { name: "#{user.name}", width: "#{size}", height: "#{size}", 'font-size' => font, 'char-count' => 2}, class: 'profile img-circle')
  #   end

  # end

end
