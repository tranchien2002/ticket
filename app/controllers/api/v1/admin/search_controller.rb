class Api::V1::Admin::SearchController < Api::V1::Admin::BaseController

  skip_before_filter :verify_authenticity_token
  before_action :verify_admin
  before_action :fetch_counts
  before_action :remote_search
  before_action :get_all_teams
  before_action :search_date_from_params

  # respond_to :html, :js

  # simple search tickets by # and user
  def topic_search
    GeneralHelpers.params_validation(:get, :topic_search, params)
    if params[:q] == 'users'
      users = User.all
    else
      users = User.user_search(params[:q])
    end

    if users.size == 0 # not a user search, so look for topics
      search_topics
      template = 'admin/search/search'
      tracker("Admin Search", "Topic Search", params[:q])

      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          template: template,
          topics: @topics
        }
      }
    elsif users.size == 1
      @user = users.first
      @topics = Topic.where(user_id: @user.id).page params[:page]
      @topic = Topic.where(user_id: @user.id).first unless @user.nil?
      template = 'admin/users/show'
      tracker("Admin Search", "User Search", params[:q])
      tracker("Agent: #{current_user.name}", "Viewed User Profile", @user.name)

      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          template: template,
          topics: @topics
          topic: @topic
        }
      }
    else
      @users = users.page params[:page]
      template = 'admin/users/users'
      tracker("Admin Search", "User Search", params[:q])

      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          template: template,
          users: users
        }
      }
    end
  end

  protected

  def search_topics
    topics_to_search = Topic.where('created_at >= ?', @start_date).where('created_at <= ?', @end_date)
    if current_user.is_restricted? && teams?
      @topics = topics_to_search.admin_search(params[:q]).tagged_with(current_user.team_list, :any => true).page params[:page]
    else
      @topics = topics_to_search.admin_search(params[:q]).page params[:page]
    end
  end

  def search_date_from_params
    GeneralHelpers.params_validation(:get, :search_date_from_params, params)
    if params[:start_date].present?
      @start_date = params[:start_date].to_datetime
    else
      @start_date = Time.zone.today-1.month
    end

    if params[:end_date].present?
      @end_date = params[:end_date].to_datetime
    else
      @end_date = Time.zone.today.at_end_of_day
    end
  end


end
