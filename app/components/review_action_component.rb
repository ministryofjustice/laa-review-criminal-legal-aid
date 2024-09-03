class ReviewActionComponent < ViewComponent::Base
  def initialize(review_action:, application:)
    @application = application
    @action = review_action
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
    when :mark_as_ready
      ready_crime_application_path(application)
    end
  end

  def method
    if action == :send_back
      :get
    else
      :put
    end
  end

  def warning
    action == :send_back
  end
end

