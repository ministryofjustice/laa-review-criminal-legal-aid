class ClientDetailsPresenter < BasePresenter
  def client_or_partner_passported
    client_benefit_type = applicant.benefit_type.presence
    partner_benefit_type = partner&.benefit_type.presence

    if client_benefit_type && client_benefit_type != 'none'
      t(:client, scope:)
    elsif partner_benefit_type && partner_benefit_type != 'none'
      t(:partner, scope:)
    else
      t(:neither, scope:)
    end
  end

  private

  def scope
    'values.client_or_partner_passported'
  end
end
