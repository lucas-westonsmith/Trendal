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
    @trend = Trend.includes(counts: :videos).find(params[:id])
  end

end
