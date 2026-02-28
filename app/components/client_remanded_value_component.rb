class ClientRemandedValueComponent < ViewComponent::Base
  include GovukComponentsHelper

  def initialize(raw_value:)
    @raw_value = raw_value

    super()
  end

  def call
    return no_answer if not_remanded?

    yes_answer
  end

  private

  attr_reader :raw_value

  def not_remanded?
    raw_value == 'no'
  end

  def answer
    t(raw_value, scope: 'values.client_remanded')
  end

  def yes_answer
    govuk_tag(text: answer, colour: 'red')
  end

  def no_answer
    tag.span { answer }
  end
end
