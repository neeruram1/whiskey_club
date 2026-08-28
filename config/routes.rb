Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root 'public#index'

  resources :meetings do
    resources :bottles
    member do
      post :toggle_attendance
      get :calendar
    end
  end

  resources :archives, only: [:index]
  resources :bottles do
    member do
      post :reveal
      post :toggle_wishlist
    end
  end
  resources :ratings
  resources :users, only: [:show]

  namespace :admin do
    resources :users, only: [:index, :destroy]

    get "rotation", to: "rotation#index"
    post "rotation/:user_id/add", to: "rotation#add", as: :add_rotation
    delete "rotation/:user_id", to: "rotation#remove", as: :remove_rotation
    post "rotation/:user_id/move", to: "rotation#move", as: :move_rotation
  end
  
  get 'stats', to: 'public#stats', as: :stats
  get 'wishlist', to: 'public#wishlist', as: :wishlist

  # Installable-app endpoints. The service worker must be served from the root
  # so its scope covers the whole site.
  get 'manifest.webmanifest', to: 'pwa#manifest', as: :pwa_manifest
  get 'service-worker.js', to: 'pwa#service_worker', as: :pwa_service_worker
  get 'offline', to: 'pwa#offline', as: :pwa_offline
  
  # get "up" => "rails/health#show", as: :rails_health_check
end
