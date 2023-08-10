require 'rails_helper'

RSpec.shared_context 'with a stubbed mailer' do
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  let(:notify_mailer_method) { :application_returned_email }

  before do
    # By default, system specs do not have the Notifier handler subscribed to the
    # event store. Here, we subscribe the Notifier handler, before each spec with
    # this shared context so that we can test.
    NotifierConfiguration.new.call(Rails.configuration.event_store)
    allow(NotifyMailer).to receive(notify_mailer_method).and_return(mailer_double)
  end
end
