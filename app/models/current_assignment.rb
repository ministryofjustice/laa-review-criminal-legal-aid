class CurrentAssignment < ApplicationStruct
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

  attribute :crime_application_id, Types::Uuid

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
    assignee != UNASSIGNED_USER
  end

  def state_key
    @state_key ||= Digest::SHA1.hexdigest(
      [assignee.id, assignee.name].join('-')
    )
  end

  class << self
    def all
      CrimeApplication.all.map(&:current_assignment)
    end

    def assigned
      all.select(&:assigned?)
    end
  end

  def assignee
    @assignee ||= projection.run(Rails.application.config.event_store).fetch(:user)
  end

  private

  def projection
    RailsEventStore::Projection
      .from_stream("Assigning$#{crime_application_id}")
      .init(-> { { user: UNASSIGNED_USER } })
      .when(ASSIGNING_EVENTS,
            ->(state, event) { state[:user] = assignee_from_event(event) })
      .when(
        Assigning::UnassignedFromUser,
        ->(state, _event) { state[:user] = UNASSIGNED_USER }
      )
  end

  def assignee_from_event(event)
    Assignee.new(
      id: event.data.fetch(:to_whom_id, nil),
      name: event.data.fetch(:to_whom_name, nil)
    )
  end
end
