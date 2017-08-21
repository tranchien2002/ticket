class Api::V1::Admin::BaseController < ApplicationController
  before_action :check_admin
  skip_before_action :verify_authenticity_token
  helper_method :show_onboarding?

  def show_onboarding?
    current_user.is_admin?
  end

  protected

  def remote_search
    @remote_search = true
  end

  def check_current_user_is_allowed? topic
    return if !topic.private || current_user.is_admin? || current_user.team_list.include?(topic.team_list.first)
    if topic.team_list.count > 0 && current_user.is_restricted? && (topic.team_list + current_user.team_list).count > 0
      render status: :forbidden
    end
  end

  def date_from_params
    if params[:start_date].present?
      @start_date = params[:start_date].to_datetime
    else
      @start_date = Time.zone.today.at_beginning_of_week
    end

    if params[:end_date].present?
      @end_date = params[:end_date].to_datetime
    else
      @end_date = Time.zone.today.at_end_of_day
    end
  end

  def fetch_counts
    if current_user.is_restricted? && teams?
      topics = Topic.tagged_with(current_user.team_list, :any => true)
      @admins = User.agents #can_receive_ticket.tagged_with(current_user.team_list, :any => true)
    else
      topics = Topic.all
      @admins = User.agents
    end
    @new = topics.unread.count
    @unread = topics.unread.count
    @pending = topics.mine(current_user.id).pending.count
    @open = topics.open.count
    @active = topics.active.count
    @mine = topics.mine(current_user.id).count
    @closed = topics.closed.count
    @spam = topics.spam.count

    return {
      admins: @admins,
      new: @new,
      unread: @unread,
      pending: @pending,
      open: @open,
      active: @active,
      mine: @mine,
      closed: @closed,
      spam: @spam
    }
  end

end
