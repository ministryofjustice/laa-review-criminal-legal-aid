class DecisionComponent < ViewComponent::Base

  include ActionView::Helpers
  include AppTextHelper
  # include StepsHelper

  attr_reader :decision

  def initialize(decision:, decision_iteration:)
    @decision = decision
    @decision_iteration = decision_iteration

    super
  end

  def call
    govuk_summary_card(title:, actions:) do |card|
      govuk_summary_list do |list|
        if interests_of_justice.present?
          list.with_row do |row|
            row.with_key { label_text(:result, scope: [:decision, :interests_of_justice] ) }
            row.with_value { interests_of_justice[:result] }
          end

          list.with_row do |row|
            row.with_key { label_text(:details, scope: [:decision, :interests_of_justice] ) }
            row.with_value { simple_format(interests_of_justice[:details]) }
          end

          list.with_row do |row|
            row.with_key { label_text(:assessed_by, scope: [:decision, :interests_of_justice] ) }
            row.with_value { interests_of_justice[:assessed_by] }
          end

          list.with_row do |row|
            row.with_key { label_text(:assessed_on, scope: [:decision, :interests_of_justice] ) }
            row.with_value { l interests_of_justice[:assessed_on], format: :compact }
          end
        end

        list.with_row do |row|
          row.with_key { label_text(:result, scope: [:decision] ) }
          row.with_value { decision.result }
        end
        
        list.with_row do |row|
          row.with_key { label_text(:details, scope: [:decision] ) }
          row.with_value { decision.details }
        end
      end
    end
  end

  private

  attr_reader :decision, :decision_iteration

  delegate :means, :interests_of_justice, to: :decision

  def actions
    [
      govuk_link_to('Change', { action: :edit, id: decision.decision_id }),
      govuk_link_to('Remove', { action: :edit, id: decision.decision_id })
    ]
  end

  def title
    safe_join(['Case', count].compact, ' ')
  end

  def count
    return unless decision_iteration
    return unless decision_iteration.size > 1

    decision_iteration.index + 1
  end
end
