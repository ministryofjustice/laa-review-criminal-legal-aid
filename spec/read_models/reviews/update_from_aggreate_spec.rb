require 'rails_helper'

RSpec.describe 'Reviews::UpdateFromAggregate' do
  describe '#call' do
    let(:application_id) { SecureRandom.uuid }
    let(:submitted_at) { '2023-04-25' }
    let(:state) { 'received' }
    let(:parent_id) { SecureRandom.uuid }
    let(:reviewer_id) { SecureRandom.uuid }

    before do
      id = application_id

      aggregate = instance_double(
        Reviewing::Review,
        id:, state:, submitted_at:, reviewer_id:, parent_id:
      )

      allow(Reviewing::LoadReview).to receive(:call).with(application_id:) {
        aggregate
      }

      event = Reviewing::ApplicationReceived.new(data: { application_id: })

      Reviews::UpdateFromAggregate.new.call(event)
    end

    describe 'the read model' do
      subject(:read_model) { Review.find_by(application_id:) }

      %i[application_id state submitted_at reviewer_id parent_id].each do |attribute|
        it "sets the #{attribute}" do
          expect(read_model.public_send(attribute)).to eq(send(attribute))
        end
      end
    end
  end
end