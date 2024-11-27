class TrendsController < ApplicationController

  def index
    # Fetch trends based on the platform parameter, defaulting to TikTok
    if params[:platform] == 'youtube'
      @youtube_trends = Trend.where(platform: 'youtube')

      @tiktok_trends = nil
    else
      @tiktok_trends = Trend.where(platform: 'tiktok')
                            .order(:rank) # Order by rank
      @youtube_trends = nil
    end
  end

  def show
    @trend = Trend.includes(:counts, :videos).find(params[:id])

    @selected_country = params[:country]
    @selected_period = params[:period]

    Rails.logger.debug "Selected Country: #{@selected_country}, Selected Period: #{@selected_period}"

    if @selected_country.present? && @selected_period.present?
      @filtered_videos = @trend.videos.joins(:count)
                                      .where(counts: { country: @selected_country, period: @selected_period })

      Rails.logger.debug "Filtered Videos: #{@filtered_videos.inspect}"
    else
      @filtered_videos = @trend.videos
    end
  end


end
