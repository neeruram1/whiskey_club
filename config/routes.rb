Rails.application.routes.draw do
  devise_for :users
  root 'public#index'

  resources :meetings do
    resources :bottles
  end

  resources :ratings
  # get "up" => "rails/health#show", as: :rails_health_check
end
