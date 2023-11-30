require 'rails_helper'

RSpec.describe Reviewing::ReceiveApplication do
  subject(:command) do
    described_class.new(
      application_id: application_id,
      submitted_at: Time.zone.now.to_s,
      parent_id: nil,
      work_stream: 'extradition'
    )
  end

  include_context 'with review'

  it 'changes the state from :nil to :open' do
    expect { command.call }.to change { review.state }
      .from(nil).to(:open)
  end

  it 'sets the work_stream' do
    expect { command.call }.to change { review.work_stream }
      .from(nil).to(Types::WorkStreamType['extradition'])
  end
end
