class Api::V1::Admin::UsersController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin, only: ['invite','invite_users']
  before_action :fetch_counts, :only => ['show']
  before_action :get_all_teams

  def index
    GeneralHelpers.params_validation(:get, :admin_list_user, params)
    @roles = [['Team', 'team'], ['Admin', 'admin'], ['Agent', 'agent'], ['Editor', 'editor'], ['User', 'user']]
    if params[:role].present?
      if params[:role] == 'team'
        @users = User.team.all.page params[:page]
      else
        @users = User.by_role(params[:role]).all.page params[:page]
      end
    else
      @users = User.all.page params[:page]
    end
    @user = User.new

    render json: {
      code: Settings.code.success,
      message: "",
      users: @users,
      user: @user
    }
  end

  def show
    GeneralHelpers.params_validation(:get, :admin_show_user, params)

    all_team = get_all_teams
    @user = User.where(id: params[:id]).first
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy người dùng"
      }
    ) unless @user

    @topics = Topic.where(user_id: @user.id).page params[:page]
    @topic = Topic.where(user_id: @user.id).first
    tracker("Agent: #{current_user.name}", "Viewed User Profile", @user.name)

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        all_team: all_team,
        topic: topic,
        topics: topics
      }
    }
  end

  def invite
  end

  def invite_users
    User.bulk_invite(params["invite.emails"], params["invite.message"], params["role"]) if params["invite.emails"].present?

    render json: {
      code: Settings.code.success,
      message: "Mời người dùng thành công",
      data: {
        redirect_to: admin_users_path
      }
    }
  end
end
