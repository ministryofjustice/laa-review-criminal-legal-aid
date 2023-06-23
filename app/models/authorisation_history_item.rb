# View Object for an authorisation history item

class AuthorisationHistoryItem
  def initialize(event)
    @event = event
  end

  delegate :data, :timestamp, :event_type, to: :@event

  def description
    I18n.t(
      event_type.demodulize.underscore,
      scope: 'event.description.authorising'
    )
  end

  def user_manager_name
    return '--' unless user_manager_id

    User.name_for user_manager_id
  end

  def user_manager_id
    @user_manager_id ||= data.fetch(:user_manager_id, nil)
  end
end
