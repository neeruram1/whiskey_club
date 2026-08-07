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
  end
  
  get 'stats', to: 'public#stats', as: :stats
  get 'wishlist', to: 'public#wishlist', as: :wishlist
  
  # get "up" => "rails/health#show", as: :rails_health_check
end
