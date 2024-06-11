class IncomePaymentsPresenter < BasePresenter
  def initialize(income_payments)
    super(
      @income_payments = income_payments
    )
  end

  def formatted_income_payments(ownership_type = 'applicant')
    return {} if @income_payments.blank?

    payments_by_owner(ownership_type)
    ordered_payments
  end

  def employment_income
    @income_payments.detect{|income_payment| income_payment.payment_type == 'employment'}
  end

  def other_work_benefits
    @income_payments.detect{|income_payment| income_payment.payment_type == 'work_benefits'}
  end

  private

  def payments_by_owner(ownership_type)
    @income_payments.select! { |income_payment| income_payment.ownership_type == ownership_type }
  end

  def ordered_payments
    return {} if @income_payments.empty?

    income_payment_types.index_with { |val| income_payment_of_type(val) }
  end

  def income_payment_of_type(type)
    @income_payments.detect { |income_payment| income_payment.payment_type == type }
  end

  def income_payment_types
    LaaCrimeSchemas::Types::OtherIncomePaymentType.values
  end
end
