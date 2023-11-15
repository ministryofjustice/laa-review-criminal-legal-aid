require 'rails_helper'

RSpec.describe Review do
  let(:application_id) { SecureRandom.uuid }
  let(:reviewer_id) { SecureRandom.uuid }

  it 'is a read only model' do
    expect(described_class.new).to be_readonly
  end

  describe '.reviewer_id_for' do
    before do
      described_class.insert({ reviewer_id:, application_id: }) # rubocop:disable Rails/SkipsModelValidations
    end

    it 'returns the reviewer id for a given application_id' do
      expect(described_class.reviewer_id_for(application_id)).to eq(reviewer_id)
    end
  end
end
