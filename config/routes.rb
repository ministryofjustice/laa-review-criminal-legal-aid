Rails.application.routes.draw do
  Rails.application.routes.draw { mount RailsEventStore::Browser => "/res" if Rails.env.development? }
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
      get 'sign-out', to: 'users/sessions#destroy', as: :destroy_user_session
      # temp underscored routes
      get 'sign_out', to: 'users/sessions#destroy'
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
      # temp underscored routes
      get 'what_do_you_want_to_do_next', to: 'send_decisions#new'
      post 'what_do_you_want_to_do_next', to: 'send_decisions#create'

      resources :decisions, only: [:create] do 
        scope module: :decisions do
          get 'interests-of-justice', to: 'interests_of_justices#edit'
          put 'interests-of-justice', to: 'interests_of_justices#update'
          # temp underscored routes
          get 'interests_of_justice', to: 'interests_of_justices#edit'
          post 'interests_of_justice', to: 'interests_of_justices#update'

          get 'overall-result', to: 'overall_results#edit'
          put 'overall-result', to: 'overall_results#update'
          # temp underscored routes
          get 'overall_result', to: 'overall_results#edit'
          post 'overall_result', to: 'overall_results#update'

          get 'comment', to: 'comments#edit'
          put 'comment', to: 'comments#update'
        end
      end
      
      get 'link-maat-id', to: 'maat_decisions#new', as: :maat_decisions
      post 'link-maat-id', to: 'maat_decisions#create'
      # temp underscored routes
      get 'link_maat_id', to: 'maat_decisions#new'
      post 'link_maat_id', to: 'maat_decisions#create'

      resources :maat_decisions, only: [:update, :destroy] do
        post :create_by_reference, on: :collection
      end
    end

    get 'applications/open/:work_stream', to: 'crime_applications#open', as: :open_work_stream
    get 'applications/closed/:work_stream', to: 'crime_applications#closed', as: :closed_work_stream

    resource :application_searches, path: 'application-searches', only: [:new] do
      get :search, on: :collection
    end
    # temp underscored routes
    get '/application_searches/new', to: 'application_searches#new'
    get '/application_searches/search', to: 'application_searches#search'

    resources :assigned_applications, path: 'assigned-applications', only: [:index, :destroy, :create] do
      post :next_application, on: :collection
    end
    # temp underscored routes
    get '/assigned_applications', to: 'assigned_applications#index'
    post '/assigned_applications', to: 'assigned_applications#create'
    post '/assigned_applications/next_application', to: 'assigned_applications#next_application'
    delete '/assigned_applications/:id', to: 'assigned_applications#destroy'

    resource :documents, only: [:show] do
      get :download, on: :member
    end
  end

  namespace :reporting do
    root to: 'user_reports#index'
    get ':report_type', to: 'user_reports#show', as: 'user_report'

    get ':report_type/:interval/latest-complete', to: 'temporal_reports#latest_complete', as: :latest_complete_temporal_report
    # temp underscored routes
    get ':report_type/:interval/latest_complete', to: 'temporal_reports#latest_complete'
    get ':report_type/:interval/:period', to: 'temporal_reports#show', as: :temporal_report
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

  # temp underscored routes
  get 'manage_users', to: 'manage_users/active_users#index'
  get 'manage_users/active_users', to: 'manage_users/active_users#index'
  get 'manage_users/revive_users/:id/edit', to: 'manage_users/revive_users#edit'
  get 'manage_users/change_roles/:id/edit', to: 'manage_users/change_roles#edit'
  patch 'manage_users/change_roles/:id', to: 'manage_users/change_roles#update'
  put 'manage_users/change_roles/:id', to: 'manage_users/change_roles#update'
  get 'manage_users/invitations/:id/confirm_destroy', to: 'manage_users/invitations#confirm_destroy'
  get 'manage_users/invitations/:id/confirm_renew', to: 'manage_users/invitations#confirm_renew'
  get 'manage_users/deactivated_users/:id/confirm_reactivate', to: 'manage_users/deactivated_users#confirm_reactivate'
  patch 'manage_users/deactivated_users/:id/reactivate', to: 'manage_users/deactivated_users#reactivate'
  get 'manage_users/deactivated_users', to: 'manage_users/deactivated_users#index'
  post 'manage_users/deactivated_users', to: 'manage_users/deactivated_users#create'
  get 'manage_users/deactivated_users/new', to: 'manage_users/deactivated_users#new'

  namespace :api do
    resources :events, only: [:create]
  end

  namespace :manage_competencies, path: 'manage-competencies' do
    root 'caseworker_competencies#index'
    resources :caseworker_competencies, path: 'caseworker-competencies', only: [:index, :edit, :update]
    resources :history, only: [:show], controller: :history
  end

  # temp underscored routes
  get 'manage_competencies', to: 'manage_competencies/caseworker_competencies#index'
  get 'manage_competencies/caseworker_competencies', to: 'manage_competencies/caseworker_competencies#index'
  get 'manage_competencies/caseworker_competencies/:id/edit', to: 'manage_competencies/caseworker_competencies#edit'
  patch 'manage_competencies/caseworker_competencies/:id', to: 'manage_competencies/caseworker_competencies#update'
  put 'manage_competencies/caseworker_competencies/:id', to: 'manage_competencies/caseworker_competencies#update'

  root 'landing_page#index'
end
