require 'rails_helper'

RSpec.shared_context 'with review', shared_context: :metadata do
  let(:application_id) { SecureRandom.uuid }

  def review
    repository.load(
      Reviewing::Review.new(application_id),
      "Reviewing$#{application_id}"
    )
  end

  def repository
    @repository ||= AggregateRoot::Repository.new(
      Rails.configuration.event_store
    )
  end
end
