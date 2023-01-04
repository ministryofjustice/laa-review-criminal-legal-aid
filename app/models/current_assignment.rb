class CurrentAssignment < ApplicationRecord
  belongs_to :user

  #
  # Current Assigment is a CQRS read model. It is configured by the
  # CurrentAssignments::Configuration class
  #
  def readonly?
    true
  end
end
