# class Decisions::InterestsOfJustice < ApplicationStruct
#   include ActiveModel::Type::Helpers::AcceptsMultiparameterTime.new
#
#   attribute? :result, Types::Params::Nil | Types::InterestsOfJusticeResult
#   attribute? :reason, Types::Params::Nil | Types::String
#   attribute? :assessed_by, Types::Params::Nil | Types::String
#   attribute? :assessed_on, Types::Params::Date
#
#   validates :result, inclusion: { in: Types::InterestsOfJusticeResult.values }
#   validates :reason, :assessed_by, presence: true
#   validates :assessed_on, presence: true
#
#   # def self.new(attributes)
#   #   super attributes.merge(assessed_on:
#   # end
#

module Decisions
  class InterestsOfJustice
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :result, :string
    attribute :reason, :string
    attribute :assessed_by, :string
    attribute :assessed_on, :date

    validates :result, inclusion: { in: Types::InterestsOfJusticeResult.values }
    validates :reason, :assessed_by, presence: true
    validates :assessed_on, presence: true
  end
end
