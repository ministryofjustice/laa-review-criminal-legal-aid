class UserAuthenticate
  def initialize(auth_hash)
    @auth_subject_id = auth_hash.uid
    @last_auth_at = Time.zone.now
    @auth_info = auth_hash.info
  end

  def authenticate!
    return nil unless user

    activate_user if user.pending_activation?

    user.update(
      first_name:, last_name:, email:, last_auth_at:
    )

    user
  end

  def user
    @user ||= find_active_user || find_invited_user
  end

  private

  attr_reader :auth_info, :auth_subject_id, :last_auth_at

  alias first_auth_at last_auth_at

  delegate :email, :first_name, :last_name, to: :@auth_info

  def activate_user
    user.assign_attributes(first_auth_at:, auth_subject_id:)
  end

  def find_active_user
    User.active.find_by(auth_subject_id:)
  end

  def find_invited_user
    User.pending_activation.find_by(email:)
  end
end
