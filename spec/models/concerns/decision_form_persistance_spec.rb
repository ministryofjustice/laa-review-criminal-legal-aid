require 'rails_helper'

RSpec.describe DecisionFormPersistance do
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:dummy_form_class) do
    Class.new do
      include DecisionFormPersistance

      attribute :example_form_attribute, :string
      validates :example_form_attribute, inclusion: { in: %w[old_value new_value] }

      class << self
        def model_name
          ActiveModel::Name.new(self, nil, 'dummy_form_class')
        end
      end

      def command_class
        Deciding::SetComment
      end
    end
  end

  let(:form_object) do
    dummy_form_class.new(
      application_id:, decision_id:, example_form_attribute:
    )
  end

  let(:user_id) { SecureRandom.uuid }
  let(:application_id) { SecureRandom.uuid }
  let(:decision_id) { SecureRandom.uuid }
  let(:example_form_attribute) { 'old_value' }

  describe '#update_with_user!' do
    subject(:update_with_user) do
      form_object.update_with_user!({ example_form_attribute: new_value }, user_id)
    end

    before { allow(Deciding::SetComment).to receive(:call) }

    context 'when attributes are changed' do
      let(:new_value) { 'new_value' }

      it 'assigns new attributes, validates the model, and persists the changes' do
        update_with_user

        expect(Deciding::SetComment).to have_received(:call).with(
          application_id: application_id, decision_id: decision_id,
          example_form_attribute: 'new_value', user_id: user_id
        )
      end
    end

    context 'when attributes are not valid' do
      let(:new_value) { 'not_a_value' }

      it 'does not persist the changes' do # rubocop:disable RSpec/MultipleExpectations
        expect { update_with_user }.to raise_error ActiveModel::ValidationError

        expect(Deciding::SetComment).not_to have_received(:call)
        expect(form_object.example_form_attribute).to eq('not_a_value')
      end
    end

    context 'when attributes are not changed' do
      let(:new_value) { 'old_value' }

      it 'does not persist the changes' do
        update_with_user

        expect(Deciding::SetComment).not_to have_received(:call)
        expect(form_object.example_form_attribute).to eq('old_value')
      end
    end
  end

  describe '.permit_params' do
    it 'permits only editable attributes' do
      params = ActionController::Parameters.new(
        { dummy_form_class: { application_id:, decision_id:, example_form_attribute: } }
      )

      permitted_params = dummy_form_class.permit_params(params)
      expect(permitted_params.keys).to contain_exactly('example_form_attribute')
    end
  end

  describe '.editable_attributes' do
    it 'returns only the attributes that are editable' do
      expect(dummy_form_class.editable_attributes).to contain_exactly(:example_form_attribute)
    end
  end

  # rubocop:enable RSpec/MultipleMemoizedHelpers
end