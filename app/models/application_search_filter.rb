class ApplicationSearchFilter < ApplicationStruct
  attribute? :assigned_user_id, Types::Params::Nil | Types::Uuid
  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :start_on, Types::Params::Nil | Types::Params::Date
  attribute? :end_on, Types::Params::Nil | Types::Params::Date
  attribute? :applicant_date_of_birth, Types::Params::Nil | Types::Params::Date

  # List of assigments uniq by user
  def assigned_user_list
    return @assigned_user_list if @assigned_user_list

    @assigned_user_list = [
      CurrentAssignment::UNASSIGNED_USER,
      CurrentAssignment::ALL_ASSIGNED_USER
    ]

    @assigned_user_list + CurrentAssignment.assigned.map(&:assignee).uniq
  end

  delegate :empty?, to: :constraints

  def constraints
    attributes.compact
  end
end
