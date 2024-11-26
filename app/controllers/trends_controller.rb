class TrendsController < ApplicationController

  def index
    @trends = Trend.all.order(:rank) # Retrieve all trends, ordered by rank
  end

  def show
    @trend = Trend.find(params[:id]) # Retrieve the trend by ID
  end

end
