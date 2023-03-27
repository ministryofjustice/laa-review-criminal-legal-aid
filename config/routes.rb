Rails.application.routes.draw do
  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  get 'users/auth/failure', to: 'errors#forbidden'


  get 'application_not_found', to: 'errors#application_not_found'
  get 'unhandled', to: 'errors#unhandled'
  get 'forbidden', to: 'errors#forbidden'

  devise_for :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }

  devise_scope :user do
    unauthenticated :user do
      root 'users/sessions#new', as: :unauthenticated_root
    end

    authenticated :user do
      root to: 'assigned_applications#index', as: :authenticated_root
      get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end

  resources :reports, only: [:show]
  resources :crime_applications, only: [:show], path: 'applications' do
    get :open, on: :collection
    get :closed, on: :collection
    get :history, on: :member
    put :complete, on: :member
    put :ready, on: :member
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
    resources :manage_users, only: [:index, :new, :create, :edit, :update] do
      resource :deactivate_users, only: [:new, :create]
    end
  end

  namespace :api do
    resources :events, only: [:create]
  end

  mount RailsEventStore::Browser => "/event_browser" if Rails.env.development?
  root 'assigned_applications#index'
end
