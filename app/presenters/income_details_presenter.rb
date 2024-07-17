require 'laa_crime_schemas'

class IncomeDetailsPresenter < BasePresenter
  def initialize(income_details)
    super(
      @income_details = income_details
    )
  end

  def formatted_employment_type
    @income_details.employment_type.join('_and_')
  end

  def formatted_partner_employment_type
    @income_details.partner_employment_type.join('_and_')
  end
end
