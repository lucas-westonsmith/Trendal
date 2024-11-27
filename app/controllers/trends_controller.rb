class TrendsController < ApplicationController

  def index
    # Default to TikTok trends if no platform is selected
    if params[:platform] == 'youtube'
      @youtube_trends = Trend.where(platform: 'youtube')
      @tiktok_trends = nil  # Don't display TikTok trends
    else
      @tiktok_trends = Trend.where(platform: 'tiktok')
      @youtube_trends = nil  # Don't display YouTube trends
    end
  end

  def show
    @trend = Trend.includes(:counts).find(params[:id])
  end

end
