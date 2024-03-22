class IncomePaymentsPresenter < BasePresenter
  def initialize(income_payments)
    super(
      @income_payments = income_payments
    )
  end

  def formatted_income_payments
    return unless @income_payments

    ordered_payments
  end

  private

  def ordered_payments
    return {} if @income_payments.empty?

    income_payment_types.index_with { |val| income_payment_of_type(val) }
  end

  def income_payment_of_type(type)
    @income_payments.detect { |income_payment| income_payment.payment_type == type }
  end

  def income_payment_types
    LaaCrimeSchemas::Types::IncomePaymentType.values
  end
end
