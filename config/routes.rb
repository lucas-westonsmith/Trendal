Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Routes for trends
  resources :trends

  # Health check route to verify the app status
  get "up" => "rails/health#show", as: :rails_health_check
  get "/profile", to: "pages#profile"

  # Routes for favorites
  resources :favorites, only: [:index] do
    # Routes to add and remove a trend from favorites
    post 'add_trend/:trend_id', to: 'favorites#add_trend', as: :add_trend
    delete 'remove_trend/:trend_id', to: 'favorites#remove_trend', as: :remove_trend
  end

  # Other possible routes
  # root "posts#index"
end
