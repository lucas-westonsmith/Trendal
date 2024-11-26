class TrendsController < ApplicationController

  def index
    @trends = Trend.all.order(:rank) # Retrieve all trends, ordered by rank
  end

  def show
    @trend = Trend.includes(:counts).find(params[:id])
  end

end
