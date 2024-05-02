class OffenceClassComponent < ViewComponent::Base
  def initialize(offence:)
    @offence = offence

    super
  end

  def call
    return not_determined_tag if not_determined?

    offence_class
  end

  private

  attr_reader :offence

  def not_determined?
    offence.offence_class.blank?
  end

  def not_determined_tag
    govuk_tag(text: I18n.t('values.class_not_determined'), colour: 'red')
  end

  def offence_class
    tag.span(class: 'govuk-caption-m') do
      tag.span [t('values.class'), offence.offence_class].join(' ')
    end
  end
end
