require 'rails_helper'

RSpec.shared_context 'with a stubbed mailer', shared_context: :metadata do
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  before do
    allow(NotifyMailer).to receive(:application_returned_email).and_return(mailer_double)
  end
end
