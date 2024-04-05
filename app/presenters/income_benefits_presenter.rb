require 'laa_crime_schemas'

class IncomeBenefitsPresenter < BasePresenter
  def initialize(income_benefits)
    super(
      @income_benefits = income_benefits
    )
  end

  def formatted_income_benefits
    return unless @income_benefits

    ordered_benefits
  end

  private

  def ordered_benefits
    return {} if @income_benefits.empty?

    income_benefit_types.index_with { |val| income_benefit_of_type(val) }
  end

  def income_benefit_of_type(type)
    @income_benefits.detect { |income_benefit| income_benefit.payment_type == type }
  end

  def income_benefit_types
    LaaCrimeSchemas::Types::IncomeBenefitType.values
  end
end
