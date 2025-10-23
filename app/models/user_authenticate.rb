class UserAuthenticate
  def initialize(auth_hash)
    @auth_subject_id = auth_hash.uid
    @last_auth_at = Time.zone.now
    @email = auth_hash.info.email
  end

  # Returns the local user if an active or invited user is found using
  # the details in the auth hash.
  #
  # Deactivated users are not returned. Users with expired invitations or
  # dormant accounts are returned but are blocked from signing in by Devise
  # see (User#active_for_authentication?)
  #
  def authenticate
    return nil unless user

    user
  end

  private

  attr_reader :auth_subject_id, :email

  def user
    @user ||= find_active_user || find_invited_user
  end

  def find_active_user
    User.active.find_by(auth_subject_id:)
  end

  def find_invited_user
    User.pending_activation.find_by(email:)
  end
end
