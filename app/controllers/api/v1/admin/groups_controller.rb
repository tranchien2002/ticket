class Api::V1::Admin::GroupsController < Api::V1::Admin::BaseController

  before_action :set_user
  before_action :verify_admin
  skip_before_filter :verify_authenticity_token



  def index
    team_tag_ids = ActsAsTaggableOn::Tagging.all.where(context: "teams").includes(:tag).map{|tagging| tagging.tag.id }.uniq
    @teams = ActsAsTaggableOn::Tag.where("id IN (?)", team_tag_ids)

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        teams: @teams,
        layout: 'admin-settings'
      }
    }
  end

  def edit
    GeneralHelpers.params_validation(:edit, :edit_group, params)
    @team = ActsAsTaggableOn::Tag.find_by_id(params[:id])

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        team: @team,
        layout: 'admin-settings'
      }
    }
  end

  def update
    GeneralHelpers.params_validation(:update, :update_group, params)
    @team = ActsAsTaggableOn::Tag.find_by_id(params[:id])
    if @team
      if @team.update_attributes(group_params)
        redirect_path({admin_groups_path: admin_groups_path}) && return
      else
        redirect_path({edit_admin_group_path: edit_admin_group_path}) && return
      end
    end
    raise APIError::Common::NotFound.new({status: 404, message: "Không tìm thấy team"})
  end

  def create
    GeneralHelpers.params_validation(:create, :create_group, params)
    tag = ActsAsTaggableOn::Tag.create(group_params)
    raise APIError::Common::ServerError.new(
      {
        status: 404,
        message: "Không tạo được tag"
      }
    ) unless tag
    if ActsAsTaggableOn::Tagging.create(tag_id: tag.id, context: "teams")
      redirect_path({admin_groups_path: admin_groups_path}) && return
    else
      redirect_path({new_admin_group_path: new_admin_group_path}) && return
    end
  end

  def destroy
    GeneralHelpers.params_validation(:destroy, :destroy_group, params)
    @team = ActsAsTaggableOn::Tag.find_by_id(params[:id])

    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy team"
    ) unless @team

    @team.taggings.destroy_all if @team.taggings.present?
    @team.destroy

    if @team.destroyed?
      render json: {
        code: Settings.code.success,
        message: "Xóa team thành công"
      }
    else
      raise APIError::Common::ServerError.new(
        status: 404,
        message: "Không xóa được team"
      )
    end

    redirect_path({admin_groups_path: admin_groups_path}) && return
  end

  protected

  def set_user
    # An admin should be able to view others API keys
    if current_user.is_admin?
      @user = params[:api_key].present? ? User.find_by_id(params[:api_key][:user_id]) : current_user
    else # An agent should be able to view their own API keys only
      @user = current_user
    end
  end

  private

  def group_params
    params.require(:acts_as_taggable_on_tag).permit(
      :name,
      :description,
      :color,
      :email_address,
      :email_name,
      :show_on_helpcenter,
      :show_on_admin,
      :show_on_dashboard
    )
  end
end
