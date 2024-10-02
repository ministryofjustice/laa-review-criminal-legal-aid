class FundingActionComponent < ViewComponent::Base
  def initialize(funding_action:, application:)
    @application = application
    @action = funding_action

    super
  end

  attr_reader :application, :action

  def call
    govuk_button_to(button_text, target, method:)
  end

  private

  def button_text
    I18n.t(action, scope: 'calls_to_action')
  end

  def target
    case action
    when :submit_decision
      crime_application_complete_path(application)
    end
  end

  def method
    :post
  end
end
