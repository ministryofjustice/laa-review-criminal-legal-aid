RSpec.shared_examples 'a MAAT value translator' do |expected_translations|
  expected_translations.each_slice(2).each do |original, expected|
    it "#{original} is translated to #{expected}" do
      expect(described_class.translate(original)).to eq(expected)
    end
  end
end

RSpec.shared_examples 'a MAAT decision value translator' do |expected_translations|
  expected_translations.each_slice(2).each do |decision_attr, expected|
    context "when #{decision_attr.each_pair.map { |k, v| "#{k} is #{v}" }.to_sentence}" do
      it "is translated to #{expected}" do
        maat_decision = Maat::Decision.new(**decision_attr)
        expect(described_class.translate(maat_decision:)).to eq(expected)
      end
    end
  end
end
