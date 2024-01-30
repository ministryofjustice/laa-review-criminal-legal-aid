class ApplicationSearchFilter < ApplicationStruct # rubocop:disable Metrics/ClassLength
  REVIEW_FILTERS = %i[assigned_status age_in_business_days].freeze
  DATASTORE_FILTERS = %i[
    applicant_date_of_birth
    application_id_in
    application_status
    reviewed_after
    reviewed_before
    search_text
    submitted_after
    submitted_before
    work_stream
    application_type
  ].freeze

  attribute? :age_in_business_days, Types::Params::Nil | Types::Params::Integer
  attribute? :applicant_date_of_birth, Types::Params::Nil | Types::Params::Date
  attribute? :application_status, Types::ReviewStatusGroup
  attribute? :assigned_status, Types::AssignedStatus | Types::Uuid
  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :submitted_after, Types::Params::Nil | Types::Params::Date
  attribute? :submitted_before, Types::Params::Nil | Types::Params::Date
  attribute? :reviewed_after, Types::Params::Nil | Types::Params::Date
  attribute? :reviewed_before, Types::Params::Nil | Types::Params::Date
  attribute? :work_stream, Types::Array.of(Types::WorkStreamType)
  attribute? :application_type, Types::Array.of(Types::ApplicationType)

  # Options for the assigned status filter
  # Includes "Unassigned", "All assigned" prepended to a list of all user names.
  # Values can be "unassigned", "assigned" or a user id.
  def assigned_status_options
    status_options = Types::ASSIGNED_STATUSES.map do |status|
      [I18n.t(status, scope: 'values.assigned_status'), status]
    end

    status_options + assigned_to_user_options
  end

  # Options for the application status filter
  # Includes 'Open', 'Completed', 'Sent back to provider' or 'All applications'
  # Values can be "open", "completed", "sent_back", "all"
  def application_status_options
    Types::REVIEW_STATUS_GROUPS.keys.map do |status|
      [I18n.t(status, scope: 'values.review_status'), status]
    end
  end

  # Options for the application age_in_business_days filter
  # Includes '0 days', '1 day', '2 days', '3 days'
  def age_in_business_days_options
    Array.new(4) do |day|
      [I18n.t('values.days_passed', count: day), day]
    end
  end

  # Hash of Datastore search constraints based on the active filters
  def datastore_params
    active_datastore_filters.each_with_object({}) do |filter, params|
      params.merge!(send("#{filter}_datastore_param"))
    end
  end

  # If the filter includes constraints related to "#age_in_business_days"
  # or "#assigned_status", we first search the local Review database. The results
  # of that query are passed as a constraint to the datastore search as the
  # #application_id_in datastore param.
  # If the result set from the local Review database query is empty, we know
  # we do not need to perform a datastore search.

  # Returns:
  # - true: If there are active review filters and the local Review database
  #   result set is empty.
  # - false: If there are no active review filters or the local Review database
  #   result set is not empty.
  def datastore_results_will_be_empty?
    !active_review_filters.empty? && application_id_in&.empty?
  end

  private

  def active_filters
    attributes.compact_blank.keys
  end

  # Returns an array of the active review filters that will be used in the local Review search.
  def active_review_filters
    active_filters & REVIEW_FILTERS
  end

  # Returns an array of the active datastore filters that will be used in the datastore search.
  def active_datastore_filters
    filters = active_filters & DATASTORE_FILTERS
    filters << :application_id_in if application_id_in
    filters
  end

  def applicant_date_of_birth_datastore_param
    { applicant_date_of_birth: }
  end

  def application_id_in_datastore_param
    { application_id_in: }
  end

  def work_stream_datastore_param
    { work_stream: }
  end

  def application_type_datastore_param
    { application_type: }
  end

  def application_status_datastore_param
    { review_status: Types::REVIEW_STATUS_GROUPS.fetch(application_status) }
  end

  def reviewed_after_datastore_param
    { reviewed_after: reviewed_after&.in_time_zone('London') }
  end

  def reviewed_before_datastore_param
    { reviewed_before: reviewed_before&.in_time_zone('London') }
  end

  def submitted_after_datastore_param
    { submitted_after: submitted_after&.in_time_zone('London') }
  end

  def submitted_before_datastore_param
    { submitted_before: submitted_before&.in_time_zone('London') }
  end

  def search_text_datastore_param
    { search_text: }
  end

  # Returns the intersection of all active review filters' application_ids.
  def application_id_in
    active_review_filters_application_ids.reduce(:&)
  end

  # Returns an array application_ids for each active review filter
  def active_review_filters_application_ids
    active_review_filters.map do |filter|
      send("#{filter}_filter_application_ids")
    end
  end

  # Returns the application_ids on Review that meet the business day filter
  # constraint for the given date.
  def age_in_business_days_filter_application_ids
    Review.by_age_in_business_days(age_in_business_days).pluck(:application_id)
  end

  # Returns the application_ids on Review that meet the assigned status filter
  # constraint for the given status.
  # If a user is specified, only applications assigned to, or reviewed by, that user are returned.
  def assigned_status_filter_application_ids
    case assigned_status
    when 'unassigned'
      Review.unassigned.pluck(:application_id)
    when 'assigned'
      CurrentAssignment.pluck(:assignment_id)
    else
      user_id = assigned_status
      CurrentAssignment.assigned_to_ids(user_id:) | Review.reviewed_by_ids(user_id:)
    end
  end

  # builds an array of [User#name, User#id] sorted by first name, last name
  def assigned_to_user_options
    ids_of_users_with_active_assignments_and_or_reviews.map { |id| [User.name_for(id), id] }.sort
  end

  def ids_of_users_with_active_assignments_and_or_reviews
    CurrentAssignment.distinct.pluck(:user_id) | Review.closed.distinct.pluck(:reviewer_id)
  end
end
