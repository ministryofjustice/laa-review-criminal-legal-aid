module Decisions
  class AddAnotherForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :add_another_decision, :boolean

    validates :add_another_decision, inclusion: [true, false]
  end
end
