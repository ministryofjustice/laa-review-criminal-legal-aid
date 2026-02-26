Rails.application.routes.draw do
  Rails.application.routes.draw { mount RailsEventStore::Browser => '/res' if Rails.env.development? }
  mount DatastoreApi::HealthEngine::Engine => '/datastore'

  unless HostEnv.production?
    authenticate :user, ->(u) { u.admin? } do
      require 'sidekiq/web'
      require 'sidekiq-scheduler/web'
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  devise_for(
    :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  )

  get 'users/auth/failure', to: 'errors#forbidden'

  devise_scope :user do
    unauthenticated :user do
      root 'users/sessions#new', as: :unauthenticated_root

      get 'dev_auth', to: 'users/dev_auth#new' if FeatureFlags.dev_auth.enabled?
    end

    authenticated :user do
      get 'sign-out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end

  scope module: :casework do
    resources :crime_applications, only: [:show], path: 'applications' do
      get :open, on: :collection
      get :closed, on: :collection
      get :history, on: :member
      put :ready, on: :member
      resource :reassign, only: [:new, :create]
      resource :return, only: [:new, :create]
      resource :complete, only: [:create]
      get 'what-do-you-want-to-do-next', to: 'send_decisions#new', as: :send_decisions
      post 'what-do-you-want-to-do-next', to: 'send_decisions#create'

      resources :decisions, only: [:create] do
        scope module: :decisions do
          get 'interests-of-justice', to: 'interests_of_justices#edit'
          put 'interests-of-justice', to: 'interests_of_justices#update'

          get 'overall-result', to: 'overall_results#edit'
          put 'overall-result', to: 'overall_results#update'

          get 'comment', to: 'comments#edit'
          put 'comment', to: 'comments#update'
        end
      end

      get 'link-maat-id', to: 'maat_decisions#new', as: :maat_decisions
      post 'link-maat-id', to: 'maat_decisions#create'

      resources :maat_decisions, only: [:update, :destroy] do
        post :create_by_reference, on: :collection
      end
    end

    get 'applications/open/:work_stream', to: 'crime_applications#open', as: :open_work_stream
    get 'applications/closed/:work_stream', to: 'crime_applications#closed', as: :closed_work_stream

    resource :application_searches, path: 'application-searches', only: [:new] do
      get :search, on: :collection
    end

    resources :assigned_applications, path: 'assigned-applications', only: [:index, :destroy, :create] do
      post :next_application, on: :collection
    end

    resource :documents, only: [:show] do
      get :download, on: :member
    end
  end

  namespace :reporting do
    root to: 'user_reports#index'
    get 'generated-reports/:id/download', to: 'generated_reports#download', as: :download_generated_report

    get ':report_type', to: 'user_reports#show', as: 'user_report'

    get ':report_type/:interval/latest-complete', to: 'temporal_reports#latest_complete',
as: :latest_complete_temporal_report
    get ':report_type/:interval/:period', to: 'temporal_reports#show', as: :temporal_report
    get 'unassigned_from_self_report/:interval/:period/caseworker/:user_id',
        to: 'caseworker_reports#show', as: :unassigned_from_self_report
    get ':report_type/:interval/:period/download', to: 'temporal_reports#download', as: :download_temporal_report
    get ':report_type/:date/at/:time', to: 'snapshots#show', as: :snapshot
    get ':report_type/now', to: 'snapshots#now', as: :current_snapshot
  end

  namespace :manage_users, path: 'manage-users' do
    root 'active_users#index'
    resources :active_users, path: 'active-users', only: [:index]
    resources :history, only: [:show], controller: :history
    resources :revive_users, path: 'revive-users', only: [:edit]
    resources :change_roles, path: 'change-roles', only: [:edit, :update]

    resources :invitations, only: [:index, :new, :destroy, :create, :update] do
      member do
        get 'confirm-destroy'
        get 'confirm-renew'
      end
    end

    resources :deactivated_users, path: 'deactivated-users', only: [:index, :new, :create] do
      member do
        get 'confirm-reactivate'
        patch 'reactivate'
      end
    end
  end

  namespace :manage_competencies, path: 'manage-competencies' do
    root 'caseworker_competencies#index'
    resources :caseworker_competencies, path: 'caseworker-competencies', only: [:index, :edit, :update]
    resources :history, only: [:show], controller: :history
  end

  root 'landing_page#index'
end
