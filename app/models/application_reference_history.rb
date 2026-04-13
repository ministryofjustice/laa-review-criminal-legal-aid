class ApplicationReferenceHistory < ApplicationStruct
  EVENT_TYPES = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser,
    Reviewing::ApplicationReceived,
    Reviewing::SentBack,
    Reviewing::Completed,
    Reviewing::MarkedAsReady,
    Deleting::SoftDeleted,
    Deleting::Archived
  ].freeze

  DELETING_EVENTS = %w[Deleting::SoftDeleted Deleting::Archived].freeze

  attribute :application, Types.Instance(CrimeApplication)

  def items
    @items ||= load_from_events
  end

  private

  def load_from_events
    events = Rails.application.config.event_store
                  .read
                  .stream(stream_name)
                  .of_type(EVENT_TYPES)
                  .to_a

    ordinal_positions = calculate_ordinal_positions(events)

    events
      .map { |event| build_history_item(event, ordinal_positions) }
      .sort_by(&:timestamp)
      .reverse
  end

  def build_history_item(event, ordinal_positions)
    application = event_application(event)
    ordinal_position = ordinal_position_for(event, ordinal_positions)
    ordinal_total = ordinal_total_for(event, ordinal_positions)
    ApplicationHistoryItem.from_event(event, application, ordinal_position:, ordinal_total:)
  end

  def calculate_ordinal_positions(events)
    apps = extract_applications_from_events(events)
    positions = build_position_map(apps)
    add_total_counts(positions, apps)
    positions
  end

  def extract_applications_from_events(events)
    events
      .reject { |e| DELETING_EVENTS.include?(e.event_type) }
      .filter_map { |e| event_application(e) }
      .uniq(&:id)
      .sort_by(&:submitted_at)
  end

  def build_position_map(apps)
    positions = {}
    apps.each do |app|
      positions[app.id] = {
        type: app.application_type,
        position: count_for_type(positions, app.application_type) + 1
      }
    end
    positions
  end

  def add_total_counts(positions, apps)
    type_counts = apps.group_by(&:application_type).transform_values(&:count)
    positions.each_value { |v| v[:total] = type_counts[v[:type]] }
  end

  def count_for_type(positions, application_type)
    positions.values.count { |v| v[:type] == application_type }
  end

  def ordinal_position_for(event, ordinal_positions)
    return nil if DELETING_EVENTS.include?(event.event_type)

    app_id = event.data[:application_id] || event.data[:assignment_id]
    ordinal_positions.dig(app_id, :position)
  end

  def ordinal_total_for(event, ordinal_positions)
    return nil if DELETING_EVENTS.include?(event.event_type)

    app_id = event.data[:application_id] || event.data[:assignment_id]
    ordinal_positions.dig(app_id, :total)
  end

  def stream_name
    "ReferenceHistory$#{application.reference}"
  end

  def event_application(event)
    return nil if event.event_type == 'Deleting::SoftDeleted'

    app_id = event.data.key?(:application_id) ? event.data[:application_id] : event.data[:assignment_id]
    CrimeApplication.find(app_id)
  end
end
