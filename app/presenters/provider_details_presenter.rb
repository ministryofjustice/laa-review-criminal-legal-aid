class ProviderDetailsPresenter < BasePresenter
  def initialize(provider_details, office_details: nil)
    super(
      @provider_details = provider_details
    )

    @office_details = office_details
  end

  def firm_name
    return if @office_details.nil?
    return error_text_for(:firm_name) if error_state?

    @office_details.firm.firmName
  end

  def office_address # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    return if @office_details.nil?
    return error_text_for(:office_address) if error_state?

    safe_join(
      [
        @office_details.office.addressLine1,
        @office_details.office.addressLine2,
        @office_details.office.addressLine3,
        @office_details.office.addressLine4,
        @office_details.office.city,
        @office_details.office.county,
        @office_details.office.postCode
      ].compact_blank, tag.br
    )
  end

  private

  def error_state?
    @office_details.in?(%i[not_found unavailable])
  end

  def error_text_for(attr)
    key = case @office_details
          when :not_found then "provider_#{attr}_not_found"
          when :unavailable then "provider_#{attr}_unavailable"
          end

    t(key, scope: 'values')
  end
end
