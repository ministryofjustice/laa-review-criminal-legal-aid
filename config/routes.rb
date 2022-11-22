Rails.application.routes.draw do
  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#logout'

  resources :crime_applications, only: [:index, :show], path: 'applications' do
    get :history, on: :member
  end
  
  resources :assigned_applications, only: [:index, :destroy, :create]

  root 'assigned_applications#index'
end
