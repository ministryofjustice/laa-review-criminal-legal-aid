require 'laa_crime_schemas/types/types'
require 'dry-schema'

module Types
  include LaaCrimeSchemas::Types

  Uuid = String
  PhoneNumber = String
  Date = Date | JSON::Date
  DateTime = DateTime | JSON::DateTime

  #
  # Map of review status groups to LaaCrimeSchemas::Types:REVIEW_APPLICATION_STATUSES
  #
  REVIEW_STATUS_GROUPS = {
    'open' => [
      Types::ReviewApplicationStatus['application_received'],
      Types::ReviewApplicationStatus['ready_for_assessment']
    ],
    'closed' => [
      Types::ReviewApplicationStatus['assessment_completed'],
      Types::ReviewApplicationStatus['returned_to_provider']
    ],
    'completed' => [
      Types::ReviewApplicationStatus['assessment_completed']
    ],
    'sent_back' => [
      Types::ReviewApplicationStatus['returned_to_provider']
    ],
    'all' => REVIEW_APPLICATION_STATUSES
  }.freeze

  ReviewStatusGroup = String.default('open'.freeze).enum(
    *REVIEW_STATUS_GROUPS.keys
  )

  USER_ROLES = %w[
    caseworker
    supervisor
  ].freeze
  UserRole = String.enum(*USER_ROLES)
  UserRoles = Array.of(UserRole)

  ASSIGNED_STATUSES = %w[
    unassigned
    assigned
  ].freeze
  AssignedStatus = String.enum(*ASSIGNED_STATUSES)

  ReturnDetails = Hash.schema(
    reason: ReturnReason,
    details: String
  )

  SortDirection = String.default('ascending'.freeze).enum('descending', 'ascending')

  SORTABLE_COLUMNS = %w[
    submitted_at
    reviewed_at
    applicant_name
  ].freeze
  SortBy = String.default('submitted_at'.freeze).enum(*SORTABLE_COLUMNS)
end
