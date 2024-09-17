class InterestsOfJusticeDecision < ApplicationStruct
  attribute :interests_of_justice, InterestsOfJusticeDecision
end

class InterestsOfJusticeDecision
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :result, :string
  attribute :details, :string
  attribute :assessed_by, :string
  attribute :assessed_on, :date

  validates :result, inclusion: { in: Types::InterestsOfJusticeResult.values }
  validates :reason, :assessed_by, presence: true
  validates :assessed_on, presence: true
end
