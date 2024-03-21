class IncomePaymentsPresenter < BasePresenter
  # NOTE: Remember to add any new types to this list otherwise it will not show on page edit
  INCOME_PAYMENT_TYPES_ORDER = %w[
    maintenance
    private_pension
    state_pension
    interest_investment
    student_loan_grant
    board_from_family
    rent
    financial_support_with_access
    from_friends_relatives
    other
  ].freeze

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

    INCOME_PAYMENT_TYPES_ORDER.index_with { |val| income_payment_of_type(val) }
  end

  def income_payment_of_type(type)
    @income_payments.detect { |income_payment| income_payment.payment_type == type }
  end
end
