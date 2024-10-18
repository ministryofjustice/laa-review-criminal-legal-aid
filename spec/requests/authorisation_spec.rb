require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe 'Authorisation' do
  let(:current_user) do
    User.create(
      email: 'Joe.EXAMPLE@justice.gov.uk',
      first_name: 'Joe',
      last_name: 'EXAMPLE',
      auth_subject_id: SecureRandom.uuid,
      first_auth_at: 1.month.ago,
      last_auth_at: 1.hour.ago,
      can_manage_others: current_user_can_manage_others,
      role: current_user_role
    )
  end

  let(:service_user_routes) do
    %w[
      application_not_found
      assigned_application
      assigned_applications
      closed_crime_applications
      crime_application
      crime_application_reassign
      crime_application_return
      crime_application_complete
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
      reporting_latest_complete_temporal_report
      reporting_snapshot
      reporting_current_snapshot
      reporting_current_temporal_report
      search_application_searches
      open_work_stream
      closed_work_stream
      edit_crime_application_decision_interests_of_justice
      crime_application_decision_interests_of_justice
      edit_crime_application_decision_overall_result
      crime_application_decision_overall_result
      edit_crime_application_decision_comment
      crime_application_decision_comment
      crime_application_decisions
      create_by_reference_crime_application_maat_decisions
      new_crime_application_maat_decision
      edit_crime_application_maat_decision
      crime_application_maat_decision
      crime_application_maat_decisions
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
    %w[
      manage_competencies_root
      manage_competencies_caseworker_competencies
      edit_manage_competencies_caseworker_competency
      manage_competencies_caseworker_competency
      manage_competencies_history
    ]
  end

  let(:data_analyst_routes) do
    %w[reporting_download_temporal_report]
  end

  let(:current_user_can_manage_others) { false }

  let(:current_user_role) { UserRole::CASEWORKER }

  include Devise::Test::IntegrationHelpers

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
      sign_in current_user
    end

    it 'can access the service' do
      get open_crime_applications_path

      expect(response).to have_http_status :ok
    end

    it 'returns "Forbidden" for all user manager and supervisor routes' do
      configured_routes.each do |route|
        next unless (user_manager_routes | supervisor_routes | data_analyst_routes).include?(route.name)

        sign_in current_user

        visit_configured_route(route)

        expect(response).to have_http_status(:forbidden), response.status.to_s + route.name
        expect(response.body).to include('Access to this service is restricted')
      end
    end
  end

  describe 'an authenticated user manager' do
    let(:current_user_can_manage_others) { true }

    include_context 'with stubbed search'

    before do
      sign_in current_user
    end

    it 'can access admin manage users' do
      get manage_users_root_path
      expect(response).to have_http_status :ok
    end

    it 'returns "Forbidden" for all service, data analysts and supervisor routes' do
      configured_routes.each do |route|
        sign_in current_user
        next unless (service_user_routes | supervisor_routes | data_analyst_routes).include?(route.name)

        visit_configured_route(route)

        expect(response).to have_http_status(:forbidden)
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
      tested_routes = user_manager_routes | service_user_routes | unauthenticated_routes |
                      supervisor_routes | data_analyst_routes

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
    id = crime_application_id = decision_id = '696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    report_type = 'processed_report'
    interval = 'monthly'
    period = '2023-August'
    date = '2023-05-01'
    time = '23:59'
    work_stream = 'criminal_applications_team'
    { id:, crime_application_id:, path:, report_type:, interval:, period:, date:,
      time:, work_stream:, decision_id: }.slice(*route.required_keys.dup)
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
