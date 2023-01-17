require 'laa_crime_schemas/types/types'
require 'dry-schema'

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

  ReturnDetails = Hash.schema(
    reason: ReturnReason,
    details: String
  )
end
