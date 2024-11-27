class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite = current_user.favorite || current_user.create_favorite
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
      redirect_to favorite_path(@favorite.id)
    else
      redirect_to trend_path(@trend)
    end
  end
end
