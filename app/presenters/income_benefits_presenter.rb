require 'laa_crime_schemas'

class IncomeBenefitsPresenter < BasePresenter
  def initialize(income_benefits)
    super(
      @income_benefits = income_benefits
    )
  end

  def applicant_income_benefits
    formatted_income_benefits('applicant')
  end

  def partner_income_benefits
    formatted_income_benefits('partner')
  end

  def formatted_income_benefits(ownership_type)
    return {} if @income_benefits.blank?

    owners_benefits = benefits_by_owner(ownership_type)
    ordered_benefits(owners_benefits)
  end

  private

  def benefits_by_owner(ownership_type)
    @income_benefits.select { |income_benefit| income_benefit.ownership_type == ownership_type }
  end

  def ordered_benefits(owners_benefits)
    return {} if owners_benefits.blank?

    income_benefit_types.index_with { |val| income_benefit_of_type(owners_benefits, val) }
  end

  def income_benefit_of_type(owners_benefits, type)
    owners_benefits.detect { |income_benefit| income_benefit.payment_type == type }
  end

  def income_benefit_types
    LaaCrimeSchemas::Types::IncomeBenefitType.values
  end
end
