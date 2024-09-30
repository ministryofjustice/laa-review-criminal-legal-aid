class DecisionComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper
  include ComponentsHelper

  def initialize(decision:, decision_iteration: nil, editable: false)
    @decision = decision
    @decision_iteration = decision_iteration

    super
  end

  def call # rubocop:disable Metrics/AbcSize
    govuk_summary_list(card: { title:, actions: }, rows: rows) do |list|
      list.with_row do |row|
        row.with_key { label_text(:funding_decision, scope: [:decision]) }
        row.with_value { decision_result(decision.funding_decision) }
      end

      list.with_row do |row|
        row.with_key { label_text(:comment, scope: [:decision]) }
        row.with_value { decision.comment }
      end
    end
  end

  private

  def actions
    []
  end

  def rows
    ioj_rows
  end

  def ioj_rows # rubocop:disable Metrics/MethodLength
    return [] if interests_of_justice.blank?

    scope = [:decision, :interests_of_justice]
    [
      {
        key: { text: label_text(:result, scope:) },
        value: { text: ioj_result }
      },
      {
        key: { text: label_text(:details, scope:) },
        value: { text: simple_format(interests_of_justice[:details]) }
      },
      {
        key: { text: label_text(:assessed_by, scope:) },
        value: { text: interests_of_justice[:assessed_by] }
      },
      {
        key: { text: label_text(:assessed_on, scope:) },
        value: { text: l(interests_of_justice[:assessed_on], format: :compact) }
      }
    ]
  end

  def ioj_result
    t(interests_of_justice[:result], scope: [:values, :decision_result])
  end

  attr_reader :decision, :decision_iteration

  delegate :means, :interests_of_justice, to: :decision

  def title
    safe_join(['Case', count].compact, ' ')
  end

  def count
    return unless decision_iteration
    return unless decision_iteration.size > 1

    decision_iteration.index + 1
  end
end
