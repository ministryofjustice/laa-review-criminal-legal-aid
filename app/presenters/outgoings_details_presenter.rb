class OutgoingsDetailsPresenter < BasePresenter
  BOARD_AND_LODGING_METADATA = %w[
    board_amount
    food_amount
    payee_name
    payee_relationship_to_client
  ].freeze

  def initialize(outgoings_details)
    super(
      @outgoings_details = outgoings_details
    )
  end

  # rubocop:disable Performance/InefficientHashSearch
  def housing_payments
    @housing_payments ||= (@outgoings_details.outgoings || []).select do |payment|
      Types::HousingPaymentType.values.include?(payment.payment_type)
    end
  end

  def council_tax
    @council_tax ||= (@outgoings_details.outgoings || []).find do |payment|
      payment.payment_type == 'council_tax'
    end
  end
  # rubocop:enable Performance/InefficientHashSearch

  def board_and_lodging
    @board_and_lodging = housing_payments.find do |payment|
      payment.payment_type == 'board_and_lodging'
    end
  end

  def board_and_lodging_metadata # rubocop:disable Metrics/MethodLength
    return {} unless board_and_lodging

    payment_type = Struct.new(:amount, :frequency)
    frequency = board_and_lodging.frequency
    metadata = board_and_lodging.metadata

    {
      'board_amount' => {
        partial: :payment_with_frequency,
        value: payment_type.new(amount: metadata.board_amount, frequency: frequency)
      },
      'food_amount' => {
        partial: :payment_with_frequency,
        value: payment_type.new(amount: metadata.food_amount, frequency: frequency)
      },
      'payee_name' => {
        partial: :simple_row,
        value: metadata.payee_name
      },
      'payee_relationship_to_client' => {
        partial: :simple_row,
        value: metadata.payee_relationship_to_client
      },
    }
  end
end
