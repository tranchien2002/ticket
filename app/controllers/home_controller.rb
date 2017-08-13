#done
class HomeController < ApplicationController

  # theme :theme_chosen
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin_and_agent

  def index
    @topics = Topic.by_popularity.ispublic.front
    @rss = Topic.chronologic.active
    # @articles = Doc.all_public_popular.with_translations(I18n.locale)
    @articles = Doc.all_public_popular
    @team = User.agents.active
    @feed_link = "<link rel='alternate' type='application/rss+xml' title='RSS' href='#{root_url}index.rss' />"
    # @categories = Category.publicly.active.ordered.featured.all.with_translations(I18n.locale)
    @categories = Category.publicly.active.ordered.featured.all

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        topics: @topics,
        rss: @rss,
        articles: @articles,
        team: @team,
        feed_link: @feed_link,
        categories: @categories
      }
    }
  end

end
