class Api::V1::Employee::TopicsController < ApplicationController
  before_action :check_Technician_and_Cashier
  skip_before_action :verify_authenticity_token

  def dashboard
    @all = Topic.where(building_id: current_user.building_id).count
    @new = Topic.neww(current_user.building_id).count
    @active = Topic.active(current_user.building_id).count
    @mine = Topic.mine(current_user.building_id, current_user.id).count
    @closed = Topic.closed(current_user.building_id).count
  end

  def index
    @status = params[:status] || "new"
    if @status == "all"
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id).order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    elsif @status == "mine"
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id, current_status: Settings.ticket_status.active, assigned_user_id: current_user.id)
        .order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    else
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id, current_status: @status).order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    end
  end

  def search
    @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
      "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
      .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
      .search(building_id_eq: current_user.building_id, name_cont: params[:keyword],
        created_at_gteq: params[:created_at], closed_date_lteq: params[:closed_date])
      .result.order(updated_at: :desc)
      .paginate(page: params[:page], per_page: Settings.per_page)
  end

  def show
    @topic = Topic.includes(:user, :assigned_user).find_by(id: params[:id])
    raise APIError::Common::NotFound unless @topic
    @posts = Post.select("users.name as user_name", "users.email as user_email", "posts.*")
      .joins(:user).where(topic_id: @topic.id)
  end

  def update_topic
    @topics = Topic.where(id: params[:topic_ids])
    raise APIError::Common::NotFound unless @topics.present?
    bulk_post_attributes = []
    if params[:change_status] == "closed"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "Công việc này đã đóng bởi #{current_user.name}.",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_close(bulk_post_attributes)
    elsif params[:change_status] == "mine"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "#{current_user.name} đã nhận công việc này.",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_agent_assign(bulk_post_attributes, current_user.id)
    elsif params[:change_status] == "new"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "Công việc này đã mở trở lại bởi #{current_user.name}",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_reopen(bulk_post_attributes)
    else
      @topics.update_all(current_status: params[:change_status], updated_at: Time.current)
    end
    render json: {code: 1, message: "Thành công"}
  end

  def assign_agent
    raise APIError::Common::BadRequest unless params[:assigned_user].present?
    assigned_user = User.find_by(uid: params[:assigned_user][:id])
    unless assigned_user
      assigned_user = User.new(
        uid: params[:assigned_user][:id],
        name: params[:assigned_user][:name],
        email: params[:assigned_user][:email],
        phone: params[:assigned_user][:phone],
        role: params[:assigned_user][:type],
        building_id: current_user.building_id
      )
      raise APIError::Common::UnSaved unless assigned_user.save
    end

    @topics = Topic.where(id: params[:topic_ids])
    raise APIError::Common::NotFound unless @topics.present?

    bulk_post_attributes = []
    @topics.each do |topic|
      bulk_post_attributes << {
        body: "Công việc này đã được gán cho #{assigned_user.name}",
        kind: 'note',
        user_id: current_user.id,
        topic_id: topic.id
      }
    end
    @topics.bulk_agent_assign(bulk_post_attributes, assigned_user.id) if bulk_post_attributes.present?
    render json: {code: 1, message: "Thành công"}
  end
end
