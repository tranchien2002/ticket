class StaticPagesController < ApplicationController
  before_action :login_required
  def index
    redirect_to Settings.sachmem_url
  end
end
