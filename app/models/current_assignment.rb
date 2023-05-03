class CurrentAssignment < ApplicationRecord
  belongs_to :user

  #
  # Current Assigment is a CQRS read model. It is configured by the
  # CurrentAssignments::Configuration class
  #
  def readonly?
    true
  end

  class << self
    # returns an array of crime application ids currently assigned to the user_id.
    def assigned_to_ids(user_id:)
      where(user_id:).pluck(:assignment_id)
    end
  end
end
