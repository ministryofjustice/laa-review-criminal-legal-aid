require 'rails_helper'

RSpec.describe Review do
  it 'is a read only model' do
    expect(described_class.new).to be_readonly
  end
end
