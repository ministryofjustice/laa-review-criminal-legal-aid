class CurrentAssignment < ApplicationStruct
  ASSIGNING_EVENTS = [
    Assigning::AssignedToUser,
    Assigning::ReassignedToUser
  ].freeze

  attribute :crime_application_id, Types::Uuid

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

  def state_key
    @state_key ||= Digest::SHA1.hexdigest(
      [user_id, user_name].join('-')
    )
  end

  private

  def data
    @data ||= projection.run(Rails.application.config.event_store).fetch(:user)
  end

  def projection
    RailsEventStore::Projection
      .from_stream("Assigning$#{crime_application_id}")
      .init(-> { { user: unassigned_user_data } })
      .when(ASSIGNING_EVENTS,
            ->(state, event) { state[:user] = event.data })
      .when(
        Assigning::UnassignedFromUser,
        ->(state, _event) { state[:user] = unassigned_user_data }
      )
  end

  def unassigned_user_data
    { user_id: nil, user_name: 'Unassigned' }
  end
end
