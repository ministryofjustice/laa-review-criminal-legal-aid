require 'laa_crime_schemas/types/types'

module Types
  include LaaCrimeSchemas::Types

  Uuid = String
  PhoneNumber = String
  Date = Date | JSON::Date
  DateTime = DateTime | JSON::DateTime

  #
  # Map of review application statuses to LaaCrimeSchemas::Types:APPLICATION_STATUSES
  #
  REVIEW_APPLICATION_STATUSES = {
    'open' => [Types::ApplicationStatus['submitted']],
    'completed' => [], # NOTE: completed status does no yet exist in datastore/schema
    'sent_back' => [Types::ApplicationStatus['returned']],
    'all' => APPLICATION_STATUSES
  }.freeze

  ReviewApplicationStatus = String.default('open'.freeze).enum(
    *REVIEW_APPLICATION_STATUSES.keys
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

  RETURN_REASONS = %w[
    clarification_required
    evidence_issue
    duplicate_application
    case_concluded
    provider_request
  ].freeze

  #
  # Is this rendered on apply? Should we add it to types?
  #
  ReturnReason = Hash.schema(
    details?: Nil | String,
    selected_reason: String.enum(*RETURN_REASONS)
  )
end
