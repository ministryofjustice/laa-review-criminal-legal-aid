class AuthorisationHistory < ApplicationStruct
  attribute :user_id, Types::Uuid

  def items
    @items ||= events.map { |event| AuthorisationHistoryItem.new(event) }
  end

  private

  def events
    Authorising.user_events(user_id).backward
  end
end
