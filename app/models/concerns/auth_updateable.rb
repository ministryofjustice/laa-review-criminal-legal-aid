# A Devise style module to update the user with information from the
# OmniAuth auth_hash on sign_in.
#
# Activates the user by setting the "auth_subject_id" and "first_auth_at"
# if the user is "pending_activation?".

require 'warden_hooks/auth_updateable'

module AuthUpdateable
  extend ActiveSupport::Concern

  class AlreadyActivated < StandardError; end

  def update_from_auth_hash!(request)
    auth_hash = request.env['omniauth.auth']
    return unless auth_hash

    if pending_activation?
      activate_from_auth_hash(auth_hash)

      Authorising::Activate.new(user: self, auth_subject_id: auth_subject_id).call
    else
      update_from_auth_hash(auth_hash)
      save!
    end
  end

  private

  def update_from_auth_hash(auth_hash)
    self.first_name = auth_hash.info.first_name
    self.last_name = auth_hash.info.last_name
    self.email = auth_hash.info.email
    self.last_auth_at = Time.zone.now
  end

  def activate_from_auth_hash(auth_hash)
    raise 'AlreadyActivated' unless pending_activation?

    update_from_auth_hash(auth_hash)
    self.first_auth_at = Time.zone.now
    self.auth_subject_id = auth_hash.uid
  end
end
