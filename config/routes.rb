Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :trends
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :favorites, only: [:index]
  post 'favorites/add_trend/:trend_id', to: 'favorites#add_trend', as: :add_trend
  delete 'favorites/remove_trend/:trend_id', to: 'favorites#remove_trend', as: :remove_trend

  # Defines the root path route ("/")
  # root "posts#index"
end
