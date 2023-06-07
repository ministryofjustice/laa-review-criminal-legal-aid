class AuthorisationHistory < ApplicationStruct
  attribute :user_id, Types::Uuid

  def items
    @items ||= events.map { |event| AuthorisationHistoryItem.new(event) }
  end

  private

  def events
    event_store.read.stream("Authorisation$#{user_id}").backward
  end

  def event_store
    Rails.application.config.event_store
  end
end
