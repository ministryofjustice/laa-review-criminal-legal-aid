require 'laa_crime_schemas'

class OutgoingPaymentsPresenter < BasePresenter
  def initialize(outgoing_payments)
    super(
      @outgoing_payments = outgoing_payments
    )
  end

  def formatted_outgoing_payments
    return unless @outgoing_payments

    ordered_payments
  end

  private

  def ordered_payments
    remove_housing_payments

    return {} if @outgoing_payments.empty?

    outgoing_payment_types.index_with { |val| outgoing_payment_of_type(val) }
  end

  def outgoing_payment_of_type(type)
    @outgoing_payments.detect { |outgoing_payment| outgoing_payment.payment_type == type }
  end

  def remove_housing_payments
    @outgoing_payments.reject! do |outgoing_payment|
      housing_payment_types.include?(outgoing_payment.payment_type)
    end
  end

  def outgoing_payment_types
    %w[childcare maintenance legal_aid_contribution]
  end

  def housing_payment_types
    %w[rent mortgage board_and_lodging]
  end
end
