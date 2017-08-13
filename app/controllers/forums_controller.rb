#done
class ForumsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  # Make sure forums are enabled
  before_action :forums_enabled?, only: ['index','show']
  # theme :theme_chosen
  before_action :verify_admin_and_agent

  def index
    @page_title = t(:community, default: "Community")
    @forums = Forum.where(private: false).order('name ASC')
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        page_title: @page_title,
        forums: @forums
      }
    }
  end

  def show
    GeneralHelpers.params_validation(:get, :show_forum, params)
    redirect_path({topics_path: topics_path(:forum_id => params[:id])}) && return
  end
end
