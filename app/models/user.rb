class User < ApplicationRecord
  class CannotDestroyIfActive < StandardError; end
  class CannotRenewIfActive < StandardError; end

  paginates_per Rails.configuration.x.admin.pagination_per_page

  devise :omniauthable, :timeoutable

  include AuthUpdateable
  include Reauthable

  before_create :set_invitation_expires_at

  before_destroy do
    raise CannotDestroyIfActive if activated?
  end

  scope :pending_activation, -> { where(auth_subject_id: nil, deactivated_at: nil) }

  scope :active, lambda {
    where('auth_subject_id IS NOT NULL AND deactivated_at IS NULL')
  }

  has_many :current_assignments, dependent: :destroy

  def name
    [first_name, last_name].compact.join(' ')
  end

  def deactivated?
    deactivated_at.present?
  end

  def activated?
    auth_subject_id.present? && first_auth_at.present?
  end

  def deactivate!
    return unless deactivatable?

    update!(deactivated_at: Time.zone.now)
  end

  def deactivatable?
    num_other_admins = User.where(
      can_manage_others: true,
      deactivated_at: nil
    ).where.not(id: self).size

    num_other_admins > 1
  end

  def pending_activation?
    auth_subject_id.nil? && first_auth_at.nil?
  end

  def invitation_expired?
    pending_activation? && invitation_expires_at < Time.zone.now
  end

  def renew_invitation!
    raise CannotRenewIfActive if activated?

    set_invitation_expires_at
    save!
  end

  def set_invitation_expires_at
    self.invitation_expires_at = Rails.configuration.x.auth.invitation_ttl.from_now
  end

  def service_user?
    !can_manage_others?
  end

  def dormant?
    activated? && last_auth_at < Rails.configuration.x.auth.dormant_account_threshold.ago
  end

  # Overwrite the Devise model's #active_for_authentication? to return false
  # if the account is dormant or the invitation has exipired.
  def active_for_authentication?
    super && !(invitation_expired? || dormant?)
  end

  # Message to be shown by Devise when active_for_authentication? is false
  def inactive_message
    if invitation_expired?
      :invitation_expired
    elsif dormant?
      :dormant
    end
  end

  class << self
    #
    # For GDPR caseworker personal data is not stored in the event stream.
    # Rendering an application's history can require many user names to be
    # found. This method caches those lookups.
    #
    # It returns "[deleted]" for a forgotten/not found user
    #
    def name_for(id)
      Rails.cache.fetch("user_names#{id}", expires_in: 10.minutes) do
        User.find(id).name
      rescue ActiveRecord::RecordNotFound
        I18n.t('values.deleted_user_name')
      end
    end
  end
end
