class Review < ApplicationRecord
  scope :closed, -> { where.not(reviewer_id: nil) }
  scope :open, -> { where(reviewer_id: nil) }

  scope :unassigned, lambda {
    open.where.not(application_id: CurrentAssignment.pluck(:assignment_id))
  }

  scope :by_age_in_business_days, lambda { |age|
    where(business_day: BusinessDay.aged(age).date)
  }

  #
  # Review is a CQRS read model. It is configured by the
  # Reviews::Configuration class
  #
  def readonly?
    true
  end

  def pse?
    application_type == 'post_submission_evidence'
  end

  class << self
    # returns an array of crime application ids reviewed by the user id.
    def reviewed_by_ids(user_id:)
      where(reviewer_id: user_id).pluck(:application_id)
    end

    def reviewer_id_for(application_id)
      Review.where(application_id:).pick(:reviewer_id)
    end
  end
end
