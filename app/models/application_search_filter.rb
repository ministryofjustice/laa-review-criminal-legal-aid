class ApplicationSearchFilter < ApplicationStruct
  attribute? :assigned_status, Types::Params::Nil | Types::Uuid | Types::String.enum('assigned', 'unassigned')
  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :submitted_after, Types::Params::Nil | Types::Params::Date
  attribute? :submitted_before, Types::Params::Nil | Types::Params::Date
  attribute? :applicant_date_of_birth, Types::Params::Nil | Types::Params::Date

  #
  # Options for the assigned status filter
  #
  # Includes "Unassigned", "All assigned" prepended to a list of all user names.
  # Values can be "unassigned", "assigned" or a user id.
  # If a user is specified, only applications assinged to that user are returned.
  #
  def assigned_status_options
    [
      [I18n.t('labels.assigned_status.unassigned'), 'unassigned'],
      [I18n.t('labels.assigned_status.assigned'), 'assigned']
    ] + assigned_to_user_options
  end

  #
  # Hash of DatastoreApi search constraints based upon the filter
  #
  # NOTE: The DatastoreApi does not understand assigned_status. To filter
  # DatastoreApi searches by assigned status, we translate the assigned_status into
  # "application_id_in" and "application_id_not_in" DatastoreApi constraints.
  #
  def as_json(_opts = {})
    {
      applicant_date_of_birth:,
      application_id_in:,
      application_id_not_in:,
      submitted_after:,
      submitted_before:,
      search_text:
    }
  end

  def state_key
    Digest::SHA256.hexdigest(as_json.values.join)
  end

  private

  def assigned_to_user_options
    User.order(:first_name, :last_name).pluck(:id).map do |id|
      [User.name_for(id), id]
    end
  end

  #
  # returns the value of the DatastoreApi Search "application_id_in" constraint
  # according to the #assigned_status
  #
  def application_id_in
    case assigned_status
    when nil, 'unassigned'
      []
    when 'assigned'
      all_assigned_application_ids
    else
      CurrentAssignment.where(user: assigned_status).pluck(:assignment_id)
    end
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
