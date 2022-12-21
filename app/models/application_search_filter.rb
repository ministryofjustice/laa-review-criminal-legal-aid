class ApplicationSearchFilter < ApplicationStruct
  attribute? :assigned_user_id, Types::Params::Nil | Types::Uuid
  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :start_on, Types::Params::Nil | Types::Params::Date
  attribute? :end_on, Types::Params::Nil | Types::Params::Date
  attribute? :applicant_date_of_birth, Types::Params::Nil | Types::Params::Date

  UNASSIGNED_USER = Assignee.new(
    id: 'd5b133b9-ed09-4c40-a818-676ea2ae5e30',
    name: 'Unassigned'
  ).freeze

  ALL_ASSIGNED_USER = Assignee.new(
    id: '395ef5e5-bd91-49f0-bcfc-fb52fffb35ed',
    name: 'All assigned'
  ).freeze

  # List of assigments uniq by user
  def assigned_user_list
    return @assigned_user_list if @assigned_user_list

    @assigned_user_list = [
      UNASSIGNED_USER,
      ALL_ASSIGNED_USER
    ]

    @assigned_user_list + users_with_assignments
  end

  delegate :empty?, to: :constraints

  def constraints
    attributes.compact
  end

  private

  def users_with_assignments
    User.where(
      id: CurrentAssignment.distinct.select(:user_id)
    )
  end
end
