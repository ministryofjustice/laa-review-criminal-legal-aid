class ReviewActionComponent < ViewComponent::Base
  def initialize(review_action:, application:)
    @application = application
    @action = review_action

    super
  end

  attr_reader :application, :action

  def call
    case action
    when :complete
      govuk_button_to(action_text, crime_application_complete_path(application), method: :post)
    when :send_back
      govuk_link_to(
        action_text,
        new_crime_application_return_path(application)
      )
    when :mark_as_ready
      govuk_button_to(action_text, ready_crime_application_path(application), method: :put)
    end
  end

  private

  def action_text
    I18n.t(action, scope: 'calls_to_action')
  end
end
