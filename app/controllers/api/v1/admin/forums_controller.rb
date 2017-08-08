class Api::V1::Admin::ForumsController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_filter :verify_authenticity_token

  def index
    @forums = Forum.where(private: false).order('name ASC')
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        forums: @forums
      }
    }
  end

  def edit
    GeneralHelpers.params_validation(:edit, :edit_forum, params)
    @forum = Forum.find_by(id: params[:id])

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        forum: @forum
      }
    }
  end

  def create
    GeneralHelpers.params_validation(:create, :create_forum, params)
    @forum = Forum.new(forum_params)
    if @forum.save
      redirect_path({admin_forums_path: admin_forums_path}) && return
    else
      redirect_path({new_forum_path: new_forum_path}) && return
    end
  end

  def update
    GeneralHelpers.params_validation(:update, :update_forum, params)
    @forum = Forum.find_by_id(params[:id])
    raise APIError::Common::NotFound.new unless @forum
    if @forum.update(forum_params)
      redirect_path({admin_forums_path: admin_forums_path}, {message: "Cập nhật Forum thành công"}) && return
    else
      redirect_path({edit_forum_path: edit_forum_path}) && return
    end
  end

  def destroy
    GeneralHelpers.params_validation(:destroy, :destroy_forum, params)
    @forum = Forum.find_by_id(params[:id])
    @forum.destroy

    if @forum.destroyed?
      render json: {
        code: Settings.code.success,
        message: "Xóa forum thành công"
      }
    else
      raise APIError::Common::ServerError.new(
        status: 404,
        message: "Không xóa được forum"
      )
    end
  end

  private

  def forum_params
    params.require(:forum).permit(
      :name,
      :description,
      :layout,
      :private,
      :allow_topic_voting,
      :allow_post_voting
    )
  end


end
