class Assignment < ApplicationStruct
  attribute :application, Types.Instance(CrimeApplication)

  def user_name
    data.fetch(:user_name)
  end

  def user_id
    data.fetch(:user_id)
  end

  def assigned_to_user(user)
    user.id.to_s == user_id
  end

  private

  def data
    return { user_id: nil, user_name: 'unassigned' } unless latest_assignment

    latest_assignment.data
  end

  def latest_assignment
    @latest_assignment ||= application.event_stream.of_type([Assigning::AssignedToUser]).first
  end
end
