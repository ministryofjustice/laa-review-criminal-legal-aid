require 'laa_crime_schemas'

class BenefitsPresenter < BasePresenter
  def initialize(benefits)
    super(
      @benefits = benefits
    )
  end

  def formatted_benefits
    return unless @benefits

    ordered_benefits
  end

  private

  def ordered_benefits
    benefit_types.index_with { |val| benefit_of_type(val) }
  end

  def benefit_of_type(type)
    @benefits.detect { |benefit| benefit.payment_type == type }
  end

  def benefit_types
    LaaCrimeSchemas::Types::IncomeBenefitType.values
  end
end
