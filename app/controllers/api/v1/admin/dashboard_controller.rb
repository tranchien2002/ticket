class Api::V1::Admin::DashboardController < Api::V1::Admin::BaseController

  # skip_before_action :verify_admin
  before_action :get_all_teams
  skip_before_action :verify_authenticity_token, raise: false

  # Routes to different views depending on role of user
  def index
    #@topics = Topic.mine(current_user.id).pending.page params[:page]

    if (current_user.is_admin? || current_user.is_agent?) && (forums? || tickets?)
      redirect_path({admin_topics_path: admin_topics_path}) && return
    elsif current_user.is_editor? && knowledgebase?
      redirect_path({admin_categories_path: admin_categories_path}) && return
    else
      redirect_path({root_url: root_url}) && return
    end
  end

end
