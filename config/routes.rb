Rails.application.routes.draw do
  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#logout'

  get 'application_not_found', to: 'errors#application_not_found'
  get 'unhandled', to: 'errors#unhandled'

  resources :reports, only: [:show]
  resources :crime_applications, only: [:show], path: 'applications' do
    get :open, on: :collection
    get :closed, on: :collection
    get :history, on: :member
    put :complete, on: :member
    resource :reassign, only: [:new, :create]
    resource :return, only: [:new, :create]
  end

  resource :application_searches, only: [:new] do
    get :search, on: :collection
  end

  resources :assigned_applications, only: [:index, :destroy, :create] do
    post :next_application, on: :collection
  end

  namespace :admin do
    resources :manage_users, only: [:index]
  end

  namespace :api do
    resources :events, only: [:create]
  end

  mount RailsEventStore::Browser => "/event_browser" if Rails.env.development?
  root 'assigned_applications#index'
end
