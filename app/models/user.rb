class User < ApplicationRecord
  devise :omniauthable, :timeoutable

  include Reauthable

  before_create do
    self.invitation_expires_at = Rails.configuration.x.auth.reauthenticate_in.from_now
  end

  scope :pending_activation, lambda {
    where('auth_subject_id IS NULL AND invitation_expires_at > ?', Time.zone.now)
  }

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

  def deactivate!
    update!(deactivated_at: Time.zone.now)
  end

  def activated?
    !auth_subject_id.nil?
  end

  def pending_activation?
    auth_subject_id.nil? && first_auth_at.nil?
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
