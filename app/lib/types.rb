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
    'open' => APPLICATION_STATUSES & ['submitted'],
    'completed' => APPLICATION_STATUSES & ['completed'],
    'sent_back' => APPLICATION_STATUSES & ['returned'],
    'all' => APPLICATION_STATUSES
  }.freeze

  ReviewApplicationStatus = String.default('open').enum(
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
end
