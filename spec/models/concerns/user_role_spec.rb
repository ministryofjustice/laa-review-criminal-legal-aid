require 'rails_helper'

RSpec.describe UserRole do
  let(:user) do
    User.new(
      email: 'example@justice.digital.gov.uk',
      auth_subject_id: SecureRandom.uuid,
      last_auth_at: 10.days.ago,
      first_auth_at: 10.days.ago
    )
  end

  describe '.role' do
    it 'defaults to `caseworker`' do
      expect(user.role).to eq 'caseworker'
    end

    context 'when role is invalid' do
      it 'fails user validation' do
        expect { user.role = 'CaSEWorker' }.to raise_error ArgumentError, "'CaSEWorker' is not a valid role"
      end

      it 'does not persist user' do
        expect { user.update_column(:role, 'CaSEWorker') } # rubocop:disable Rails/SkipsModelValidations
          .to raise_error StandardError
      end
    end
  end

  describe '#can_read_application?' do
    context 'when user is supervisor' do
      it 'returns true' do
        user.role = 'supervisor'
        expect(user.can_read_application?).to be true
      end
    end

    context 'when user is caseworker' do
      it 'returns true' do
        user.role = 'caseworker'
        expect(user.can_read_application?).to be true
      end
    end
  end

  describe '#can_write_application?' do
    context 'when user is supervisor' do
      it 'returns true' do
        user.role = 'supervisor'
        expect(user.can_write_application?).to be true
      end
    end

    context 'when user is caseworker' do
      it 'returns false' do
        user.role = 'caseworker'
        expect(user.can_write_application?).to be false
      end
    end
  end

  describe '#service_user?' do
    context 'when user is not a user manager' do
      it 'returns true for caseworker or supervisor' do
        user.can_manage_others = false

        Types::UserRole.values.each do |role| # rubocop:disable Style/HashEachMethods
          user.role = role
          expect(user.service_user?).to be true
        end
      end
    end

    context 'when user is a user manager' do
      it 'returns false for caseworker or supervisor' do
        user.can_manage_others = true

        Types::UserRole.values.each do |role| # rubocop:disable Style/HashEachMethods
          user.role = role
          expect(user.service_user?).to be false
        end
      end
    end
  end

  describe '#user_manager?' do
    context 'with can_manager_others attribute set to true' do
      it 'returns true' do
        user.can_manage_others = true
        expect(user.user_manager?).to be true
      end
    end
  end

  describe '#can_change_role?' do
    context 'when user is active' do
      it 'returns true' do
        expect(user.activated?).to be true
        expect(user.can_change_role?).to be true
      end
    end

    context 'when user is not activated' do
      before do
        user.first_auth_at = nil
      end

      it 'returns false' do
        expect(user.activated?).to be false
        expect(user.can_change_role?).to be false
      end
    end

    context 'when feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:basic_user_roles) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'returns false' do
        expect(user.activated?).to be true
        expect(user.can_change_role?).to be false
      end
    end

    context 'when user is dormant' do
      before do
        user.last_auth_at = 100.days.ago
        user.first_auth_at = 100.days.ago
      end

      it 'returns false' do
        expect(user.dormant?).to be true
        expect(user.can_change_role?).to be false
      end
    end

    context 'when user is deactivated' do
      before do
        user.deactivated_at = Time.zone.now
      end

      it 'returns false' do
        expect(user.deactivated?).to be true
        expect(user.can_change_role?).to be false
      end
    end
  end

  describe '#toggle_role' do
    context 'when user is caseworker' do
      before do
        user.role = 'caseworker'
        user.save!
        user.toggle_role
      end

      it 'sets role to supervisor but does not persist' do
        expect(user.role).to eq 'supervisor'
        expect(user.reload.role).to eq 'caseworker'
      end

      it 'always returns supervisor' do
        user.toggle_role # second toggle
        expect(user.role).to eq 'supervisor'
      end
    end

    context 'when user is supervisor' do
      before do
        user.role = 'supervisor'
        user.save!
        user.toggle_role
      end

      it 'sets role to caseworker but does not persist' do
        expect(user.role).to eq 'caseworker'
        expect(user.reload.role).to eq 'supervisor'
      end

      it 'always returns caseworker' do
        user.toggle_role # second toggle
        expect(user.role).to eq 'caseworker'
      end
    end
  end
end
