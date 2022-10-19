Rails.application.routes.draw do

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'


  resources :crime_applications, only: [:index, :show], path: 'applications'

  root 'crime_applications#index'
end
