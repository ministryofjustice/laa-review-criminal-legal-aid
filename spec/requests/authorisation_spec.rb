require 'rails_helper'
RSpec.describe 'Authorisation' do
  include Devise::Test::IntegrationHelpers

  let(:service_user_routes) do
    %w[
      assigned_application
      assigned_applications
      closed_crime_applications
      complete_crime_application
      crime_application
      crime_application_reassign
      crime_application_return
      crime_applications
      history_crime_application
      new_application_searches
      new_crime_application_reassign
      new_crime_application_return
      next_application_assigned_applications
      open_crime_applications
      ready_crime_application
      report
      search_application_searches
    ]
  end

  let(:user_manager_routes) do
    %w[
      admin_manage_users_active_user
      admin_manage_users_active_users
      admin_manage_users_deactivated_users
      admin_manage_users_invitation
      admin_manage_users_invitations
      admin_manage_users_root
      confirm_destroy_admin_manage_users_invitation
      confirm_renew_admin_manage_users_invitation
      edit_admin_manage_users_active_user
      new_admin_manage_users_deactivated_user
      new_admin_manage_users_invitation
    ]
  end

  let(:unauthenticated_routes) do
    %w[
      authenticated_root
      dev_auth
      forbidden
      health
      ping
      preview_view_component
      preview_view_components
      root
      unauthenticated_root
    ]
  end

  let(:authenticated_routes) do
    %w[
      application_not_found
      not_found
      unhandled
    ]
  end

  describe 'an unauthenticated user' do
    it 'can access all unauthenticated routes' do
      configured_routes.each do |route|
        next unless unauthenticated_routes.include?(route.name)

        visit_configured_route(route)
        status = route.name == 'forbidden' ? :forbidden : :ok

        expect(response).to have_http_status(status)
      end
    end

    it 'is redirected to "sign in" for all authenticated routes' do
      configured_routes.select { |r| unauthenticated_routes.exclude?(r.name) }.each do |route|
        visit_configured_route(route)

        expect(response).to redirect_to(unauthenticated_root_path)
        follow_redirect!
        expect(response.body).to include('Sign in to view this page')
      end
    end

    it 'is redirected to "sign in" for a non-existent url' do
      get '/this_is_not_a/route'

      expect(response).to redirect_to(unauthenticated_root_path)
      follow_redirect!
      expect(response.body).to include('Sign in to view this page')
    end
  end

  describe 'an authenticated service user' do
    include_context 'with stubbed search'
    before do
      user = User.create(email: 'Ben.EXAMPLE@example.com')
      sign_in user
    end

    it 'can access the service' do
      get open_crime_applications_path

      expect(response).to have_http_status :ok
    end

    it 'is redirected to "Not found" for all user manager routes' do
      configured_routes.each do |route|
        next unless user_manager_routes.include?(route.name)

        visit_configured_route(route)

        expect(response).to redirect_to(not_found_path)
      end
    end
  end

  describe 'an authenticated user manager' do
    include_context 'with stubbed search'

    before do
      user = User.create(email: 'Ben.EXAMPLE@example.com', can_manage_others: true)
      sign_in user
    end

    it 'can access admin manage users' do
      get admin_manage_users_root_path
      expect(response).to have_http_status :ok
    end

    it 'is redirected to "admin manage users root" for all service routes' do
      configured_routes.each do |route|
        next unless service_user_routes.include?(route.name)

        visit_configured_route(route)

        expect(response).to redirect_to(admin_manage_users_root_path)
      end
    end

    context 'when user managers are allowed service access' do
      before do
        # Override allow_user_managers_service_access as per staging
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      it 'can access admin manage users' do
        get admin_manage_users_root_path
        expect(response).to have_http_status :ok
      end

      it 'can access the service' do
        get open_crime_applications_path
        expect(response).to have_http_status :ok
      end
    end
  end

  it 'all configured routes are tested' do
    configured_routes.each do |route|
      tested_routes = user_manager_routes + service_user_routes + unauthenticated_routes + authenticated_routes

      expect(tested_routes.include?(route.name)).to be(true), "\"#{route.name}\" is not tested"
    end
  end

  def configured_routes
    Rails.application.routes.routes.dup.select do |r|
      r.name.present? && outside_the_scope_of_this_test.exclude?(r.name)
    end
  end

  def outside_the_scope_of_this_test
    %w[
      _system_test_entrypoint
      api_events
      destroy_user_session
      turbo_recede_historical_location
      turbo_refresh_historical_location
      turbo_resume_historical_location
      user_azure_ad_omniauth_authorize
      user_azure_ad_omniauth_callback
    ]
  end

  # processs a request according to the routes path and https method
  def visit_configured_route(route)
    url_helper = [route.name, 'path'].join('_')
    path = send(url_helper.to_sym, dummy_params(route))
    process(route.verb.downcase.to_sym, path)
  end

  # Returns the params required to construct a valid path
  def dummy_params(route)
    path = '/'
    id = crime_application_id = '696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    { id:, crime_application_id:, path: }.slice(*route.required_keys.dup)
  end
end
