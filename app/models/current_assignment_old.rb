class CurrentAssignmentOld < ApplicationStruct
  def initialize(opts)
    throw 'OI'
  end

  UNASSIGNED_USER = Assignee.new(
    id: 'd5b133b9-ed09-4c40-a818-676ea2ae5e30',
    name: 'Unassigned'
  ).freeze

  ALL_ASSIGNED_USER = Assignee.new(
    id: '395ef5e5-bd91-49f0-bcfc-fb52fffb35ed',
    name: 'All assigned'
  ).freeze

  ASSIGNING_EVENTS = [
    Assigning::AssignedToUser,
    Assigning::ReassignedToUser
  ].freeze

  attribute :assignment_id, Types::Uuid

  def assigned_to_user?(user)
    assigned? && user.id.to_s == assignee.id
  end

  def user_id
    assignee.id
  end

  def user_name
    assignee.name
  end

  def assigned?
    !assigned_user_id.nil?
  end

  def state_key
    @state_key ||= Digest::SHA1.hexdigest(
      [assignee.id, assignee.name].join('-')
    )
  end

  def assignee
    return @assignee if @assignee
    return UNASSIGNED_USER unless assigned_user_id

    @assignee = User.find(assigned_user_id)
  end

  private

  def assigned_user_id
    @assigned_user_id ||= assigned_user_projection.run(
      Rails.application.config.event_store
    ).fetch(:user_id)
  end

  def assigned_user_projection
    RailsEventStore::Projection
      .from_stream("Assigning$#{assignment_id}")
      .init(-> { { user_id: nil } })
      .when(ASSIGNING_EVENTS,
            ->(state, event) { state[:user_id] = event.data.fetch(:to_whom_id) })
      .when(
        Assigning::UnassignedFromUser,
        ->(state, _event) { state[:user_id] = nil }
      )
  end
end
