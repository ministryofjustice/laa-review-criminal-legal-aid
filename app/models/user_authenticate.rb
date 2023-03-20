class UserAuthenticate
  def initialize(auth_hash)
    @auth_subject_id = auth_hash.uid
    @auth_expires_at = Time.zone.now + auth_hash.credentials.expires_in
    @last_auth_at = Time.zone.now
    @auth_info = auth_hash.info
  end

  def authenticate!
    return nil unless user
    return nil if user.deactivated?

    user.update!(auth_details)

    user
  end

  def user
    @user ||= User.find_by(auth_subject_id:) || User.find_by(email:)
  end

  private

  attr_reader :auth_expires_at, :auth_info, :auth_subject_id, :last_auth_at

  delegate :email, :first_name, :last_name, to: :@auth_info

  def auth_details
    details = {
      first_name:,
      last_name:,
      email:,
      last_auth_at:,
      auth_expires_at:
    }

    return details unless user.pending_authentication?

    details[:auth_subject_id] = auth_subject_id
    details[:first_auth_at] = last_auth_at

    details
  end
end
