require 'rails_helper'

RSpec.describe 'Reporting temporal reports' do
  include Devise::Test::IntegrationHelpers

  let(:user) do
    User.create!(
      first_name: 'Business',
      last_name: 'Support',
      email: "business-support-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::BUSINESS_SUPPORT
    )
  end

  let(:report) { instance_double(Reporting::SlipstreamAuditReport, csv_file_count: 1, csv: '') }
  let(:filter) { { offence: 'Burglary', selection_reason: 'age' } }

  before do
    allow(Reporting::SlipstreamAuditReport).to receive(:for_time_period).and_return(report)
    sign_in user
  end

  describe 'slipstream audit report filters' do
    it 'forwards the offence and selection reason filters to the report' do
      get '/reporting/slipstream_audit_report/monthly/2025-October/download', params: { filter: }

      expect(Reporting::SlipstreamAuditReport).to have_received(:for_time_period)
        .with(hash_including(filter))
    end

    it 'preserves both filters when redirecting to the latest complete report' do
      get '/reporting/slipstream_audit_report/monthly/latest-complete', params: { filter: }

      expect(response.location).to include('filter%5Boffence%5D=Burglary', 'filter%5Bselection_reason%5D=age')
    end
  end
end
