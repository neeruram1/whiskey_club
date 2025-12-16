Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root 'public#index'

  resources :meetings do
    resources :bottles
  end

  resources :archives, only: [:index]
  resources :bottles, except: [:show] # Bottle show is handled by meeting show
  resources :ratings
  
  get 'stats', to: 'public#stats', as: :stats
  
  # Redirect old bottle URLs to meeting page
  get 'bottles/:id', to: redirect { |params, request|
    bottle = Bottle.find(params[:id])
    "/meetings/#{bottle.meeting_id}#{request.query_string.present? ? "?#{request.query_string}" : ""}"
  }
  
  # get "up" => "rails/health#show", as: :rails_health_check
end
