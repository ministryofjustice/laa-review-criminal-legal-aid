class OffenceDatesComponent < ViewComponent::Base
  def initialize(offence:)
    @offence = offence

    super
  end

  def call
    safe_join(dates)
  end

  private

  attr_reader :offence

  def dates
    offence.dates.map do |date|
      tag.p(class: ['govuk-body', 'govuk-!-margin-bottom-0']) { date_content(date) }
    end
  end

  def date_content(date)
    return I18n.l(date.date_from, format: :compact) unless date.date_to

    [l(date.date_from, format: :compact), l(date.date_to, format: :compact)].join(' – ')
  end
end
