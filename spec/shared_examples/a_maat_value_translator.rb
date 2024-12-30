RSpec.shared_examples 'a MAAT value translator' do |expected_translations|
  expected_translations.each_slice(2).each do |original, expected|
    it "#{original} is translated to #{expected}" do
      expect(described_class.translate(original)).to eq(expected)
    end
  end
end
