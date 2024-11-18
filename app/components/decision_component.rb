class DecisionComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper
  include ComponentsHelper

  def initialize(decision:, decision_iteration: nil, show_actions: false)
    @decision = decision
    @decision_iteration = decision_iteration
    @show_actions = show_actions

    super
  end

  private

  attr_reader :decision, :decision_iteration, :show_actions

  delegate :means, :interests_of_justice, to: :decision

  def actions
    return [] unless draft? && show_actions

    [change_action, remove_action].compact
  end

  def draft?
    decision.is_a? Decisions::Draft
  end

  def linked_to_maat?
    decision.maat_id.present?
  end

  def change_action
    if linked_to_maat?
      button_to(action_text(:update_from_maat), update_path, method: :patch, class: 'govuk-link app-button--link')
    else
      govuk_link_to(
        action_text(:change), crime_application_decision_interests_of_justice_path(decision.to_param)
      )
    end
  end

  def remove_action
    return unless linked_to_maat?

    button_to(
      action_text(:unlink_decision),
      crime_application_maat_decision_path(
        crime_application_id: decision.application_id, id: decision.decision_id
      ),
      method: :delete,
      class: 'govuk-link app-button--link'
    )
  end

  def update_path
    crime_application_maat_decision_path(
      crime_application_id: decision.application_id, id: decision.decision_id
    )
  end

  def ioj_result
    t(interests_of_justice.result, scope: [:values, :decision_result])
  end

  def date(value)
    l(value, format: :compact)
  end

  def means_result
    t(means.result, scope: [:values, :decision_result])
  end

  def title
    safe_join([label_text(:decision_card_title), count].compact, ' ')
  end

  def count
    return unless decision_iteration
    return unless decision_iteration.size > 1

    decision_iteration.index + 1
  end
end
