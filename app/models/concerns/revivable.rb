# A Devise style module to describe `revive` conditions for `dormant` users

require 'warden_hooks/revivable'

module Revivable
  extend ActiveSupport::Concern

  def dormant?
    return false if awaiting_revival? # Give dormant user opportunity to log in

    revivable?
  end

  def revivable?
    activated? && last_auth_at.present? && last_auth_at < Rails.configuration.x.auth.dormant_account_threshold.ago
  end

  def awaiting_revival?
    revivable? && revive_until.present? && revive_until > Time.zone.now
  end
end
