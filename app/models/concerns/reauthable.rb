# A Devise style module to enforce the maximum time that can pass between
# authentications regardless of user activity.
#

require 'warden_hooks/reauthable'

module Reauthable
  extend ActiveSupport::Concern

  def auth_expired?
    return false unless reauthenticate_in && last_auth_at

    last_auth_at < reauthenticate_in.ago
  end

  private

  def reauthenticate_in
    Rails.configuration.x.auth.reauthenticate_in
  end
end
