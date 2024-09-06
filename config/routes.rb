Rails.application.routes.draw do
  mount DatastoreApi::HealthEngine::Engine => '/datastore'

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  devise_for(
    :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  )

  get "users/auth/failure", to: "errors#forbidden"

  devise_scope :user do
    unauthenticated :user do
      root 'users/sessions#new', as: :unauthenticated_root

      if FeatureFlags.dev_auth.enabled?
        get 'dev_auth', to: 'users/dev_auth#new'
      end
    end

    authenticated :user do
      get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end

  scope module: :casework do
    resources :crime_applications, only: [:show], path: 'applications' do
      get :open, on: :collection
      get :closed, on: :collection
      get :history, on: :member
      put :complete, on: :member
      put :ready, on: :member
      resource :reassign, only: [:new, :create]
      resource :return, only: [:new, :create]
      post 'add_a_funding_decision', to: 'decisions#create'

      resources :decisions do
        scope module: :decisions do
          resource :interests_of_justice
        end
      end
    end

    get 'applications/open/:work_stream', to: 'crime_applications#open', as: :open_work_stream
    get 'applications/closed/:work_stream', to: 'crime_applications#closed', as: :closed_work_stream

    resource :application_searches, only: [:new] do
      get :search, on: :collection
    end

    resources :assigned_applications, only: [:index, :destroy, :create] do
      post :next_application, on: :collection
    end

    resource :documents, only: [:show] do
      get :download, on: :member
    end
  end

  namespace :reporting do
    root to: 'user_reports#index'
    get ':report_type', to: 'user_reports#show', as: 'user_report'

    get ':report_type/:interval/latest_complete', to: 'temporal_reports#latest_complete', as: :latest_complete_temporal_report
    get ':report_type/:interval/:period', to: 'temporal_reports#show', as: :temporal_report
    get ':report_type/:interval/:period/download', to: 'temporal_reports#download', as: :download_temporal_report
    get ':report_type/:date/at/:time', to: 'snapshots#show', as: :snapshot
    get ':report_type/now', to: 'snapshots#now', as: :current_snapshot
  end

  namespace :manage_users do
    root 'active_users#index'
    resources :active_users, only: [:index]
    resources :history, only: [:show], controller: :history
    resources :revive_users, only: [:edit]
    resources :change_roles, only: [:edit, :update]

    resources :invitations, only: [:index, :new, :destroy, :create, :update] do
      member do
        get 'confirm_destroy'
        get 'confirm_renew'
      end
    end

    resources :deactivated_users, only: [:index, :new, :create] do
      member do
        get 'confirm_reactivate'
        patch 'reactivate'
      end
    end
  end

  namespace :api do
    resources :events, only: [:create]
  end

  namespace :manage_competencies do
    root 'caseworker_competencies#index'
    resources :caseworker_competencies, only: [:index, :edit, :update]
    resources :history, only: [:show], controller: :history
  end

  root 'landing_page#index'
end
