class PersonPresenter < BasePresenter
  def phone_number
    return if telephone_number.nil?

    format_telephone_number(telephone_number)
  end

  def formatted_nino
    return if nino.nil?

    nino
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def format_telephone_number(number)
    # Remove all spaces
    formatted_tel = number.gsub(/\s+/, '')

    case formatted_tel
    when /\A07\d{9}\z/ # Mobile number with exactly 11 digits
      [5, 9].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+447\d{9}\z/ # +44 mobile number format without initial 0
      [3, 8, 12].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+4407\d{9}\z/ # +44 mobile number format with initial 0
      [3, 9, 13].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+44\(0\)7\d{9}\z/ # +44 mobile numberformat with initial 0 in parentheses
      [3, 7, 12, 16].each { |i| formatted_tel.insert i, ' ' }
    else
      formatted_tel = telephone_number
    end

    formatted_tel
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
end
