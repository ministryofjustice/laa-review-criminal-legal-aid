require 'rails_helper'
RSpec.describe 'Authorisation' do
  include Devise::Test::IntegrationHelpers

  let(:service_user_routes) do
    %w[
      application_not_found
      assigned_application
      assigned_applications
      closed_crime_applications
      complete_crime_application
      crime_application
      crime_application_reassign
      crime_application_return
      crime_applications
      download_documents
      documents
      history_crime_application
      new_application_searches
      new_crime_application_reassign
      new_crime_application_return
      next_application_assigned_applications
      open_crime_applications
      ready_crime_application
      reporting_user_report
      reporting_root
      reporting_temporal_report
      reporting_snapshot
      reporting_current_snapshot
      reporting_current_temporal_report
      search_application_searches
    ]
  end

  let(:user_manager_routes) do
    %w[
      manage_users_active_user
      manage_users_active_users
      manage_users_change_role
      manage_users_deactivated_users
      manage_users_history
      manage_users_invitation
      manage_users_invitations
      manage_users_root
      confirm_destroy_manage_users_invitation
      confirm_reactivate_manage_users_deactivated_user
      confirm_renew_manage_users_invitation
      edit_manage_users_active_user
      edit_manage_users_change_role
      edit_manage_users_revive_user
      new_manage_users_deactivated_user
      new_manage_users_invitation
      reactivate_manage_users_deactivated_user
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
      users_auth_failure
    ]
  end

  let(:supervisor_routes) do
    %w[]
  end

  def expected_status(route_name)
    case route_name
    when 'users_auth_failure', 'forbidden'
      :forbidden
    when 'unhandled'
      :internal_server_error
    when 'not_found', 'application_not_found'
      :not_found
    else
      :ok
    end
  end

  describe 'an unauthenticated user' do
    it 'can access all unauthenticated routes' do
      configured_routes.each do |route|
        next unless unauthenticated_routes.include?(route.name)

        visit_configured_route(route)

        expect(response).to have_http_status(expected_status(route.name))
      end
    end

    it 'is redirected to "sign in" for all authenticated routes' do
      configured_routes.select { |r| unauthenticated_routes.exclude?(r.name) }.each do |route|
        visit_configured_route(route)

        expect(response).to redirect_to(unauthenticated_root_path)
        follow_redirect!
        expect(response.body).to include('Sign in to access the service')
      end
    end
  end

  describe 'an authenticated service user (caseworker)' do
    include_context 'with stubbed search'
    before do
      user = User.create(email: 'Ben.EXAMPLE@example.com')
      sign_in user
    end

    it 'can access the service' do
      get open_crime_applications_path

      expect(response).to have_http_status :ok
    end

    it 'returns "Not found" for all user manager and supervisor routes' do
      configured_routes.each do |route|
        next unless (user_manager_routes & supervisor_routes).include?(route.name)

        visit_configured_route(route)

        expect(response).to have_http_status :not_found
        expect(response.body).to include('Page not found')
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
      get manage_users_root_path
      expect(response).to have_http_status :ok
    end

    it 'is redirected to "admin manage users root" for all service and supervisor routes' do
      configured_routes.each do |route|
        next unless (service_user_routes & supervisor_routes).include?(route.name)

        visit_configured_route(route)

        expect(response).to redirect_to(manage_users_root_path)
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
        get manage_users_root_path
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
      tested_routes = user_manager_routes + service_user_routes + unauthenticated_routes + supervisor_routes

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
      datastore_api_health_engine
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
    report_type = 'processed_report'
    interval = 'monthly'
    period = '2023-August'
    date = '2023-05-01'
    time = '23:59'
    { id:, crime_application_id:, path:, report_type:, interval:, period:, date:,
time: }.slice(*route.required_keys.dup)
  end
end
