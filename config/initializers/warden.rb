require 'warden/strategies/azure_ad'

Warden::Strategies.add(:azure_ad, Warden::Strategies::AzureAd)

Rails.application.config.middleware.insert_before(OmniAuth::Builder, Warden::Manager) do |manager|
  manager.default_scope = :user
  manager.scope_defaults :user, strategies: [:azure_ad]
  manager.failure_app = Warden::AzureAdFailureController

  manager.serialize_into_session(:user) do |user_id|
    [user_id]
  end

  manager.serialize_from_session(:user) do |user_session_data|
    User.find(user_session_data.last)
  end
end

Warden::Manager.after_set_user do |user,auth,opts|
  # TODO: implement session timeout.
  #
  # scope = opts[:scope]
  #
  # if auth.session["#{scope}.last_access_at"].to_i > (Time.zone.now - SESSION_TIMEOUT).to_i
  #   auth.logout(scope)
  #   throw(:warden, :scope => scope, :reason => "Times Up")
  # end
  #
  # auth.session["#{scope}.last_access_at"] = Time.zone.now
end
