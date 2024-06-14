class IncomePaymentsPresenter < BasePresenter
  def initialize(income_payments)
    super(
      @income_payments = income_payments
    )
  end

  def applicant_income_payments
    formatted_income_payments('applicant')
  end

  def partner_income_payments
    formatted_income_payments('partner')
  end

  def formatted_income_payments(ownership_type)
    return {} if @income_payments.blank?

    owners_payments = payments_by_owner(ownership_type)
    ordered_payments(owners_payments)
  end

  def employment_income
    @income_payments&.detect { |income_payment| income_payment.payment_type == 'employment' }
  end

  def other_work_benefits
    @income_payments&.detect { |income_payment| income_payment.payment_type == 'work_benefits' }
  end

  private

  def payments_by_owner(ownership_type)
    @income_payments.select { |income_payment| income_payment.ownership_type == ownership_type }
  end

  def ordered_payments(owners_payments)
    return {} if owners_payments.blank?

    income_payment_types.index_with { |val| income_payment_of_type(owners_payments, val) }
  end

  def income_payment_of_type(owners_payments, type)
    owners_payments.detect { |income_payment| income_payment.payment_type == type }
  end

  def income_payment_types
    LaaCrimeSchemas::Types::OtherIncomePaymentType.values
  end
end
