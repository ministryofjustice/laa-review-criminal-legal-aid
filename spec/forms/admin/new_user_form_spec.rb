require 'rails_helper'

RSpec.describe Admin::NewUserForm, type: :model do
  let(:valid_params) { { email: 'user@example.com', can_manage_others: true } }
  let(:invalid_params) { { email: 'invalid_email', can_manage_others: nil } }
  let(:blank_params) { { email: '', can_manage_others: nil } }
  let(:user) { instance_double(User, save: true) }
  let(:user_class) { class_double(User).as_stubbed_const }

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

        it 'errors when email is not unique (i.e. user already exists)' do
          allow(user_class).to receive(:create!).with(valid_params).and_raise(ActiveRecord::RecordNotUnique)

          form = described_class.new(valid_params)
          form.save

          expect(form.errors[:email]).to include('User already exists')
        end
      end
    end
  end

  describe '#save' do
    subject(:save) { described_class.new(valid_params).save }

    before do
      allow(user_class).to receive(:create!).with(valid_params).and_return(user)
      allow(NotifyMailer).to receive(:access_granted_email) {
        instance_double(ActionMailer::MessageDelivery, deliver_now: true)
      }
    end

    context 'with valid params' do
      before do
        allow(user_class).to receive(:create!).with(valid_params).and_return(user)
      end

      it { is_expected.to be true }

      it 'creates a new user' do
        save
        expect(user_class).to have_received(:create!).with(valid_params)
        expect(NotifyMailer).to have_received(:access_granted_email).with(valid_params[:email])
      end
    end

    context 'with invalid params' do
      subject(:save) { described_class.new(invalid_params).save }

      before { allow(user_class).to receive(:create!) }

      it { is_expected.to be false }

      it 'does not create a new user' do
        save
        expect(user_class).not_to have_received(:create!)
        expect(NotifyMailer).not_to have_received(:access_granted_email)
      end
    end

    context 'when an active record error is raised' do
      before do
        allow(user_class).to receive(:create!) {
          raise ActiveRecord::RecordNotUnique
        }
      end

      it { is_expected.to be false }

      it 'does not create a new user' do
        save
        expect(user_class).to have_received(:create!)
        expect(NotifyMailer).not_to have_received(:access_granted_email)
      end
    end
  end
end
