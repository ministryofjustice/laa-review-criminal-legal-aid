require 'rails_helper'

RSpec.describe Admin::NewUserForm, type: :model do
  let(:valid_params) { { email: 'user@example.com', can_manage_others: true } }
  let(:invalid_params) { { email: 'invalid_email', can_manage_others: nil } }
  let(:blank_params) { { email: 'invalid_email', can_manage_others: nil } }

  describe 'validations' do
    context 'with valid params' do
      it 'is valid' do
        form = described_class.new(valid_params)
        expect(form).to be_valid
      end
    end

    context 'with invalid params' do
      it 'is not valid' do
        form = described_class.new(invalid_params)
        expect(form).not_to be_valid
      end

      describe 'form validations' do
        it 'errors when email is invalid' do
          form = described_class.new(invalid_params)
          form.valid?
          expect(form.errors[:email]).to include('Invalid email format')
        end

        it 'errors when email is blank' do
          form = described_class.new(blank_params)
          form.valid?
          expect(form.errors[:email]).to include('Please enter an email')
        end
      end
    end
  end

  describe '#save' do
    let(:user) { instance_double(User, save: true) }
    let(:user_class) { class_double(User).as_stubbed_const }

    before do
      allow(user_class).to receive(:new).with(valid_params).and_return(user)
    end

    context 'with valid params' do
      it 'creates a new user' do
        described_class.new(valid_params).save

        expect(user_class).to have_received(:new)
          .with(valid_params)
        expect(user).to have_received(:save)
      end
    end

    context 'with invalid params' do
      it 'does not create a new user' do
        described_class.new(invalid_params).save

        expect(user_class).not_to have_received(:new)
      end
    end
  end
end
