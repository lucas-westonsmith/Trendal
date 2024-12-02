class TrendsController < ApplicationController
  def index
    @keyword = params[:keyword]
    scraper = YoutubeScraper.new(@keyword)
    scraper.call

    # Fetch trends based on the platform parameter, defaulting to TikTok
    if params[:platform] == 'youtube'
      @youtube_trends = Trend.where(platform: 'youtube')
      @tiktok_trends_hashtag = nil
      @tiktok_trends_keyword = nil
    else
      # If the platform is TikTok, separate trends for hashtags and keywords
      if params[:platform] == 'tiktok'
        @tiktok_trends_hashtag = Trend.where(platform: 'tiktok', tiktok_page: 'hashtag').order(:rank)
        @tiktok_trends_keyword = Trend.where(platform: 'tiktok', tiktok_page: 'keyword').order(:rank)
      else
        @tiktok_trends_hashtag = nil
        @tiktok_trends_keyword = nil
      end
      @youtube_trends = nil
    end
  end


  def show
    @trend = Trend.includes(:counts, :videos).find(params[:id])

    @selected_country = params[:country] || 'US'
    @selected_period = params[:period] || '7'

    # Afficher les paramètres dans les logs
    Rails.logger.debug "Selected Country: #{@selected_country}, Selected Period: #{@selected_period}"

    # Préparer les données pour le graphique
    @graph_data_7_days = {}
    @graph_data_30_days = {}
    @graph_data_120_days = {}
    @graph_data_365_days = {}

    # Regrouper les counts par pays et période
    @trend.counts.group_by(&:country).each do |country, counts|
      counts.each do |count|
        country_name_with_flag = count.country_name_with_flag

        case count.period
        when 7
          @graph_data_7_days[country_name_with_flag] = count.number
        when 30
          @graph_data_30_days[country_name_with_flag] = count.number
        when 120
          @graph_data_120_days[country_name_with_flag] = count.number
        when 365
          @graph_data_365_days[country_name_with_flag] = count.number
        end
      end
    end

    # Loguer l'array de vidéos avant le filtrage
    Rails.logger.debug "Videos before filtering: #{@trend.videos.inspect}"

    # Filtrer les vidéos en fonction du pays et de la période si spécifié
    if @selected_country.present? && @selected_period.present?
      @filtered_videos = @trend.videos.joins(:count)
                                      .where(counts: { country: @selected_country, period: @selected_period })

      # Afficher les vidéos filtrées dans les logs
      Rails.logger.debug "Filtered Videos: #{@filtered_videos.inspect}"
    else
      @filtered_videos = @trend.videos
    end

    Rails.logger.debug "Interests before filtering: #{@trend.related_interests.inspect}"

    # Filtrer les intérêts en fonction du pays et de la période si spécifié
    if @selected_country.present? && @selected_period.present?
      @filtered_interests = @trend.related_interests.joins(:count)
                                          .where(counts: { country: @selected_country, period: @selected_period })

      # Afficher les intérêts filtrés dans les logs
      Rails.logger.debug "Filtered Interests: #{@filtered_interests.inspect}"
    else
      @filtered_interests = @trend.related_interests
    end

    if @selected_country.present? && @selected_period.present?
      @filtered_keyword_examples = @trend.keyword_examples
                                          .where(country: @selected_country, period: @selected_period)

      # Afficher les intérêts filtrés dans les logs
      Rails.logger.debug "Filtered Keyword Examples: #{@filtered_keyword_examples.inspect}"
    else
      @filtered_keyword_examples = @trend.keyword_examples
    end

  end
end
