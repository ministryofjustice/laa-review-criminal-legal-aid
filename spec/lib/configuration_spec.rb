require 'rails_helper'

describe Configuration do
  subject(:configuration) do
    described_class.new(
      scope: scope,
      settings_file: file_fixture('mock_settings.yml')
    )
  end

  let(:scope) { 'feature_flags' }

  describe '#config' do
    it 'returns a config based on the scope provided' do
      expect_config = { dev_auth: { local: true, staging: false } }
      expect(configuration.config).to eq(expect_config.with_indifferent_access)
    end

    context 'when the settings include ERB' do
      let(:scope) { 'settings' }

      it 'converts ERB tags in the settings file' do
        # mock yaml is: "foo: <%= 'bar from ERB'.sub(' from ERB', '') %>"
        expect_config = { foo: 'bar' }
        expect(configuration.config).to eq(expect_config.with_indifferent_access)
      end
    end
  end
end
