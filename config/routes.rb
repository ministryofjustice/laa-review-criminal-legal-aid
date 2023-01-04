Rails.application.routes.draw do
  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#logout'

  get 'application_not_found', to: 'errors#application_not_found'
  get 'unhandled', to: 'errors#unhandled'

  resources :crime_applications, only: [:index, :show], path: 'applications' do
    get :history, on: :member
    resource :reassign, only: [:new, :create]
  end

  resource :application_searches, only: [:create, :new] do
    post :download, on: :collection
  end

  resources :assigned_applications, only: [:index, :destroy, :create] do
    post :next_application, on: :collection
  end

  mount RailsEventStore::Browser => "/event_browser" if Rails.env.development?
  root 'assigned_applications#index'
end
