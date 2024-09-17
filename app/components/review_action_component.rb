class ReviewActionComponent < ViewComponent::Base
  def initialize(review_action:, application:)
    @application = application
    @action = review_action

    super
  end

  attr_reader :application, :action

  def call
    govuk_button_to(button_text, target, method:, warning:)
  end

  private

  def button_text
    I18n.t(action, scope: 'calls_to_action')
  end

  def target
    case action
    when :complete
      complete_crime_application_path(application)
    when :send_back
      new_crime_application_return_path(application)
    when :add_funding_decision
      crime_application_decisions_path(application)
    when :mark_as_ready
      ready_crime_application_path(application)
    end
  end

  def method
    case action
    when :send_back
      :get
    when :add_funding_decision
      add_funding_decision_method
    else
      :put
    end
  end

  def add_funding_decision_method
    return :get unless application.review.decision_ids.empty?

    :post
  end

  def warning
    action == :send_back
  end
end
