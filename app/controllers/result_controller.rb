#done
class ResultController < ApplicationController
  skip_before_filter :verify_authenticity_token
  theme :theme_chosen
  before_action :verify_admin_and_agent

  def index
    GeneralHelpers.params_validation(:get, :result_index, params)
    @results = PgSearch.multisearch(params[:q]).page params[:page]
    @page_title = "Chúng tôi có thể làm gì giúp bạn?"
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        results: @results,
        page_title: @page_title
      }
    }
    # add_breadcrumb 'Search'
  end

  def search
    GeneralHelpers.params_validation(:get, :search_result, params)
    depth = params[:depth].present? ? params[:depth] : 10
    @results = PgSearch.multisearch(params[:query]).first(depth)
    render json: {
      code: 1,
      message: "",
      data: {
        search_result: serialize_autocomplete_result(@results).to_json.html_safe
      }
    }
  end

  private

  def serialize_autocomplete_result(results)
    serialized_result = []
    results.each do |result|
      if result.searchable_type == "Topic"
        serialized_result << {
          name: result.searchable.name,
          content: result.searchable.post_cache.nil? ? nil : result.searchable.post_cache.truncate_words(20),
          link: topic_posts_path(Topic.find(result.searchable_id))
          }
      else
        serialized_result << {
          name: result.searchable.title,
          content: result.searchable.body.nil? ? nil : result.searchable.body.truncate_words(20),
          link: category_doc_path(result.searchable.category_id, Doc.find(result.searchable_id))
        }
      end
    end
    serialized_result
  end

end
