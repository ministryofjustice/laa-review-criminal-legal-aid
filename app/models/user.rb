class User < ApplicationRecord
  class CannotDestroyIfActive < StandardError; end
  class CannotRenewIfActive < StandardError; end
  class CannotDeactivate < StandardError; end
  class CannotReactivate < StandardError; end
  class CannotAwaitRevival < StandardError; end
  class CannotRevive < StandardError; end
  class CannotChangeRole < StandardError; end

  paginates_per Rails.configuration.x.admin.pagination_per_page

  devise :omniauthable, :timeoutable

  include AuthUpdateable
  include Reauthable
  include Revivable
  include UserRole
  include UserCompetence

  before_create :set_invitation_expires_at

  before_destroy do
    raise CannotDestroyIfActive if activated?
  end

  attr_readonly :email, :can_manage_others

  validates :email, uniqueness: true, on: :create
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :pending_activation, -> { where(auth_subject_id: nil, deactivated_at: nil) }

  scope :active, lambda {
    where('auth_subject_id IS NOT NULL AND deactivated_at IS NULL')
  }

  scope :admins, -> { active.where(can_manage_others: true) }

  scope :deactivated, lambda {
    where('auth_subject_id IS NOT NULL AND deactivated_at IS NOT NULL')
  }

  scope :caseworker, -> { active.where(role: Types::CASEWORKER_ROLE, can_manage_others: false) }

  has_many :current_assignments, dependent: :destroy

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name_or_email
    return name unless pending_activation?

    email
  end

  def caseworker_presenter
    @caseworker_presenter ||= CaseworkerPresenter.present(self)
  end

  def history
    @history ||= AuthorisationHistory.new(user_id: id)
  end

  def deactivated?
    deactivated_at.present?
  end

  def activated?
    auth_subject_id.present? && first_auth_at.present?
  end

  def deactivate!
    raise CannotDeactivate unless deactivatable?

    update!(deactivated_at: Time.zone.now)
  end

  def deactivatable?
    num_other_admins = User.active.where(can_manage_others: true).where.not(id: self).size

    num_other_admins > 1
  end

  def reactivate!
    raise CannotReactivate unless deactivated?

    update!(deactivated_at: nil)
  end

  def pending_activation?
    auth_subject_id.nil? && first_auth_at.nil?
  end

  def invitation_expired?
    pending_activation? && invitation_expires_at && invitation_expires_at < Time.zone.now
  end

  def renew_invitation!
    raise CannotRenewIfActive if activated?

    set_invitation_expires_at
    save!
  end

  def set_invitation_expires_at
    self.invitation_expires_at = Rails.configuration.x.auth.invitation_ttl.from_now
  end

  # Overwrite the Devise model's #active_for_authentication? to return false
  # if the account is dormant or the invitation has expired.
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
