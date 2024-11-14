require 'laa_crime_schemas/types/types'
require 'dry-schema'

module Types
  include LaaCrimeSchemas::Types

  Uuid = Strict::String.constrained(
    format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i
  )

  PhoneNumber = String
  Date = Date | JSON::Date
  DateTime = JSON::DateTime | Nominal::DateTime
  MaatId = Params::Integer
  DecisionId = Uuid | MaatId
  AuthSubjectId = String

  #
  # Map of review status groups to LaaCrimeSchemas::Types:REVIEW_APPLICATION_STATUSES
  #
  REVIEW_STATUS_GROUPS = {
    'all' => REVIEW_APPLICATION_STATUSES,
    'open' => [
      Types::ReviewApplicationStatus['application_received'],
      Types::ReviewApplicationStatus['ready_for_assessment']
    ],
    'closed' => [
      Types::ReviewApplicationStatus['assessment_completed'],
      Types::ReviewApplicationStatus['returned_to_provider']
    ],
    'completed' => [Types::ReviewApplicationStatus['assessment_completed']],
    'sent_back' => [
      Types::ReviewApplicationStatus['returned_to_provider']
    ],
  }.freeze

  ReviewStatusGroup = String.default('all'.freeze).enum(
    *REVIEW_STATUS_GROUPS.keys
  )

  ReviewState = Symbol.default(:open).enum(*%i[open sent_back completed marked_as_ready])

  DecisionState = Symbol.enum(*%i[draft sent_to_provider])

  ReviewType = Symbol.enum(*%i[means non_means pse])

  CASEWORKER_ROLE = 'caseworker'.freeze
  SUPERVISOR_ROLE = 'supervisor'.freeze
  DATA_ANALYST_ROLE = 'data_analyst'.freeze
  USER_ROLES = [
    CASEWORKER_ROLE,
    SUPERVISOR_ROLE,
    DATA_ANALYST_ROLE
  ].freeze
  UserRole = String.default(CASEWORKER_ROLE).enum(*USER_ROLES)

  ASSIGNED_STATUSES = %w[
    unassigned
    assigned
  ].freeze
  AssignedStatus = String.enum(*ASSIGNED_STATUSES)

  ReturnDetails = Hash.schema(
    reason: ReturnReason,
    details: String
  )

  Report = String.enum(*%w[
                         caseworker_report
                         processed_report
                         workload_report
                         return_reasons_report
                         current_workload_report
                       ])

  SnapshotReportType = String.enum(Report['workload_report'])
  TemporalReportType = String.enum(Report['caseworker_report'],
                                   Report['return_reasons_report'])

  TemporalInterval = String.enum('daily', 'weekly', 'monthly')

  USER_ROLE_REPORTS = {
    UserRole[CASEWORKER_ROLE] => [Report['current_workload_report'], Report['processed_report']],
    UserRole[DATA_ANALYST_ROLE] => Report.values,
    UserRole[SUPERVISOR_ROLE] => Report.values
  }.freeze

  SortDirection = String.enum('descending', 'ascending')

  SORTABLE_COLUMNS = %w[
    submitted_at
    time_passed
    reviewed_at
    applicant_name
  ].freeze
  SortBy = String.default('submitted_at'.freeze).enum(*SORTABLE_COLUMNS)

  APPLICATION_TYPE_COMPETENCIES = %w[
    change_in_financial_circumstances
    post_submission_evidence
    initial
  ].freeze

  WORK_STREAM_COMPETENCIES = %w[
    criminal_applications_team
    criminal_applications_team_2
    extradition
    non_means_tested
  ].freeze

  CompetencyType = String.enum(
    *WORK_STREAM_COMPETENCIES, *APPLICATION_TYPE_COMPETENCIES
  )
end
