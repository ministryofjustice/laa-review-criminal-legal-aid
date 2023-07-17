class ApplicationSearchFilter < ApplicationStruct
  attribute? :assigned_status, Types::AssignedStatus | Types::Uuid
  attribute? :application_status, Types::ReviewStatusGroup
  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :submitted_after, Types::Params::Nil | Types::Params::Date
  attribute? :submitted_before, Types::Params::Nil | Types::Params::Date
  attribute? :applicant_date_of_birth, Types::Params::Nil | Types::Params::Date

  #
  # Options for the assigned status filter
  #
  # Includes "Unassigned", "All assigned" prepended to a list of all user names.
  # Values can be "unassigned", "assigned" or a user id.
  # If a user is specified, only applications assinged to or reviewed by that
  # user are returned.
  #
  def assigned_status_options
    status_options = Types::ASSIGNED_STATUSES.map do |status|
      [I18n.t(status, scope: 'values.assigned_status'), status]
    end

    status_options + assigned_to_user_options
  end

  #
  # Options for the application status filter
  #
  # Includes 'Open', 'Completed', 'Sent back to provider' or 'All applications'
  # Values can be "open", "completed", "sent_back", "all"
  #
  def application_status_options
    Types::REVIEW_STATUS_GROUPS.keys.map do |status|
      [I18n.t(status, scope: 'values.review_status'), status]
    end
  end

  #
  # Hash of DatastoreApi search constraints based upon the filter
  #
  # NOTE: The DatastoreApi does not understand assigned_status. To filter
  # DatastoreApi searches by assigned status, we translate the assigned_status into
  # "application_id_in" and "application_id_not_in" DatastoreApi constraints.
  #
  def datastore_params
    {
      applicant_date_of_birth: applicant_date_of_birth,
      application_id_in: application_id_in,
      application_id_not_in: application_id_not_in,
      review_status: review_status,
      submitted_after: submitted_after&.in_time_zone('London'),
      submitted_before: submitted_before&.in_time_zone('London'),
      search_text: search_text
    }
  end

  private

  def assigned_to_user_options
    user_ids = (
      CurrentAssignment.distinct.pluck(:user_id) + Review.distinct.pluck(:reviewer_id)
    ).uniq

    user_ids.map { |id| [User.name_for(id), id] }.sort
  end

  # Returns the value of the DatastoreApi Search "application_id_in" constraint
  # according to the #assigned_status. Assigned status can be either nil, 'unassigned',
  # 'assigned' or a user_id.
  #
  # When assigned_status is a user_id, it returns the application_ids of those
  # applications that are either currently assigned to or were reviewed by
  # the given user.
  def application_id_in
    case assigned_status
    when nil, 'unassigned'
      []
    when 'assigned'
      all_assigned_application_ids
    else
      application_ids_for_user(assigned_status)
    end
  end

  def application_ids_for_user(user_id)
    CurrentAssignment.assigned_to_ids(user_id:) +
      Review.reviewed_by_ids(user_id:)
  end

  #
  # returns the value of the DatastoreApi Search "review_status" constraint
  # according to the #application_status
  #
  def review_status
    Types::REVIEW_STATUS_GROUPS.fetch(application_status)
  end

  #
  # returns the value of the DatastoreApi Search "application_id_not_in" constraint
  # according to the #assigned_status
  #
  # In order to get a list of unassigned applications from the Datastore,
  # we use this constraint to get a list of applications not in the list of current
  # assignments.
  #
  def application_id_not_in
    return [] unless assigned_status == 'unassigned'

    all_assigned_application_ids
  end

  def all_assigned_application_ids
    @all_assigned_application_ids ||= CurrentAssignment.pluck(:assignment_id)
  end
end
