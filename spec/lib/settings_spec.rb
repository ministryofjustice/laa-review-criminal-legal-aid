require 'rails_helper'

describe Settings do
  before do
    # override whatever is in the settings file with these settings
    # so that tests are predictable
    allow(
      described_class.instance
    ).to receive(:config).and_return(
      {
        phase_banner_tag: {
          local: 'Development',
          staging: 'Staging Beta',
          production: 'Beta'
        },
        tag_colour: {
          local: 'red',
          staging: 'white',
          production: 'blue'
        }
      }.with_indifferent_access
    )
  end

  context 'when local environment' do
    it 'returns the setting for the local HostEnv' do
      expect(described_class.phase_banner_tag).to eq 'Development'
    end
  end

  context 'when production environment on staging server' do
    before do
      allow(described_class.instance).to receive(:env_name).and_return(HostEnv::STAGING)
    end

    it 'returns the setting for the staging HostEnv' do
      expect(described_class.tag_colour).to eq 'white'
    end
  end

  context 'when production environment on production server' do
    before do
      allow(described_class.instance).to receive(:env_name).and_return(HostEnv::PRODUCTION)
    end

    it 'returns the setting for the staging HostEnv' do
      expect(described_class.tag_colour).to eq 'blue'
    end
  end

  context 'with a setting is defined in the config' do
    it 'responds true' do
      expect(described_class.respond_to?(:tag_colour)).to be true
    end
  end

  context 'when a method defined on the superclass' do
    it 'responds true' do
      expect(described_class.respond_to?(:object_id)).to be true
    end
  end

  context 'when unknown method' do
    it 'responds false' do
      expect(described_class.respond_to?(:not_a_setting)).to be false
    end

    it 'raises an exception' do
      expect { described_class.not_a_setting }.to raise_exception(NoMethodError)
    end
  end
end
