Rails.application.routes.draw do
  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#logout'

  resources :crime_applications, only: [:index, :show], path: 'applications' do
    post :assign_to_self, on: :member
  end

  root 'crime_applications#index'
end
