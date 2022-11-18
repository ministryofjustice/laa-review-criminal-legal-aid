# READ MODEL
class CurrentAssignment < ApplicationStruct
  attribute :application, Types.Instance(CrimeApplication)

  def user_name
    data.fetch(:user_name)
  end

  def user_id
    data.fetch(:user_id)
  end

  def assigned_to_user?(user)
    assigned? && user.id.to_s == user_id
  end

  def assigned?
    !user_id.nil?
  end

  private

  def data
    @data ||= projection.run(Rails.application.config.event_store).fetch(:user)
  end

  def projection
    RailsEventStore::Projection
      .from_stream("Assigning$#{application.id}")
      .init(-> { { user: unassigned_user_data } })
      .when(
        Assigning::AssignedToUser,
        ->(state, event) { state[:user] = event.data }
      )
      .when(
        Assigning::UnassignedFromSelf,
        ->(state, _event) { state[:user] = unassigned_user_data }
      )
  end

  def unassigned_user_data
    { user_id: nil, user_name: 'Unassigned' }
  end
end
