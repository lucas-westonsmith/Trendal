class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite = current_user.favorite || current_user.create_favorite

    if params[:platform].blank?
      params[:platform] = 'tiktok'
      params[:tiktok_page] = 'hashtag'  # Default to 'hashtag' if no TikTok page is specified
    end

    if params[:platform].present?
      @favorite_trends = @favorite.trends.where(platform: params[:platform])

      if params[:platform] == 'tiktok'
        case params[:tiktok_page]
        when 'hashtag'
          @favorite_tiktok_hashtags = @favorite_trends.where(tiktok_page: 'hashtag')
        when 'keyword'
          @favorite_tiktok_keywords = @favorite_trends.where(tiktok_page: 'keyword')
        when 'product'
          @favorite_tiktok_products = @favorite_trends.where(tiktok_page: 'product')
        else
          @favorite_tiktok_hashtags = @favorite_trends.where(tiktok_page: 'hashtag')
        end
      elsif params[:platform] == 'youtube'
        @favorite_youtube_trends = @favorite_trends
      end
    else
      @favorite_trends = @favorite.trends
    end

    @favorite_tiktok_hashtags ||= []
    @favorite_tiktok_keywords ||= []
    @favorite_tiktok_products ||= []

    # DATA FOR THE GRAPHS
    # Data for hashtags
    @tiktok_data_graph_for_hashtags_count = @favorite_tiktok_hashtags.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:count]
    end

    @tiktok_data_graph_for_hashtags_count_overall = @favorite_tiktok_hashtags.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:count_overall]
    end

    # Data for keywords
    @bubble_chart_keyword_one = @favorite_tiktok_keywords.map do |trend|
      { x: trend[:ctr], y: trend[:cpa], r: trend[:impression_count] / 1000.0, label: trend[:title] }
    end

    @bubble_chart_keyword_two = @favorite_tiktok_keywords.map do |trend|
      { x: trend[:impression_count], y: trend[:cvr], r: trend[:cost] / 1000.0, label: trend[:title] }
    end

    @bubble_chart_keyword_three = @favorite_tiktok_keywords.map do |trend|
      { x: trend[:like_count], y: trend[:share_count], r: trend[:comment_count] / 1000.0, label: trend[:title] }
    end

    @tiktok_data_graph_for_keywords_popularity = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:popularity]
    end

    @tiktok_data_graph_for_keywords_popularity_change = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:popularity_change]
    end

    @tiktok_data_graph_for_keywords_ctr = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:ctr]
    end

    @tiktok_data_graph_for_keywords_cvr = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cvr]
    end

    @tiktok_data_graph_for_keywords_cpa = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cpa]
    end

    @tiktok_data_graph_for_keywords_cost = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cost]
    end

    @tiktok_data_graph_for_keywords_impression_count = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:impression_count]
    end

    @tiktok_data_graph_for_keywords_view_rate_6s = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:view_rate_6s]
    end

    @tiktok_data_graph_for_keywords_like_count = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:like_count]
    end

    @tiktok_data_graph_for_keywords_share_count = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:share_count]
    end

    @tiktok_data_graph_for_keywords_comment_count = @favorite_tiktok_keywords.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:comment_count]
    end

    # Data for products
    @bubble_chart_product_one = @favorite_tiktok_products.map do |trend|
      { x: trend[:ctr], y: trend[:cpa], r: trend[:impression_count] / 1000.0, label: trend[:title] }
    end

    @bubble_chart_product_two = @favorite_tiktok_products.map do |trend|
      { x: trend[:impression_count], y: trend[:cvr], r: trend[:cost] / 1000.0, label: trend[:title] }
    end

    @bubble_chart_product_three = @favorite_tiktok_products.map do |trend|
      { x: trend[:like_count], y: trend[:share_count], r: trend[:comment_count] / 1000.0, label: trend[:title] }
    end

    @tiktok_data_graph_for_products_popularity = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:popularity]
    end

    @tiktok_data_graph_for_products_popularity_change = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:popularity_change]
    end

    @tiktok_data_graph_for_products_ctr = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:ctr]
    end

    @tiktok_data_graph_for_products_cvr = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cvr]
    end

    @tiktok_data_graph_for_products_cpa = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cpa]
    end

    @tiktok_data_graph_for_products_cost = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:cost]
    end

    @tiktok_data_graph_for_products_impression_count = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:impression_count]
    end

    @tiktok_data_graph_for_products_view_rate_6s = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:view_rate_6s]
    end

    @tiktok_data_graph_for_products_like_count = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:like_count]
    end

    @tiktok_data_graph_for_products_share_count = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:share_count]
    end

    @tiktok_data_graph_for_products_comment_count = @favorite_tiktok_products.each_with_object({}) do |trend, data|
      data[trend[:title]] = trend[:comment_count]
    end
  end

  def add_trend
    @favorite = current_user.favorite || current_user.create_favorite
    @trend = Trend.find(params[:trend_id])

    unless @favorite.trends.include?(@trend)
      @favorite.trends << @trend
      flash[:notice] = 'This trend has been added to your collection!'
    else
      flash[:alert] = 'This trend is already in your collection.'
    end

    if params[:from_action] == "index"
      redirect_to trends_path
    else
      redirect_to trend_path(@trend)
    end
  end

  def remove_trend
    @favorite = current_user.favorite
    @trend = Trend.find(params[:trend_id])

    if @favorite.trends.include?(@trend)
      @favorite.trends.delete(@trend)
      flash[:notice] = 'This trend has been removed from your collection.'
    else
      flash[:alert] = 'This trend is not in your collection.'
    end
    if params[:from_action] == "index"
      redirect_to trends_path
    elsif params[:from_action] == "favorite"
      # Ensure the user stays on the favorite page if they are already there
      redirect_to request.referer || favorite_path(@favorite.id)
    else
      redirect_to trend_path(@trend)
    end
  end
end
