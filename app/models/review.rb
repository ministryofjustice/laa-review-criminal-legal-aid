class Review < ApplicationRecord
  #
  # Review is a CQRS read model. It is configured by the
  # Reviews::Configuration class
  #
  def readonly?
    true
  end

  class << self
    # returns an array of crime application ids reviewed by the user id.
    def reviewed_by_ids(user_id:)
      where(reviewer_id: user_id).pluck(:application_id)
    end
  end
end
