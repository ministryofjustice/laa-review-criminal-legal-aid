require 'omniauth/strategies/azure_ad'


# In response to CVE-2015-9284. OmniAuth was modified to only allow
# post requests by default. This app is not thought to be vulnerable to the attack
# described in CVE-2015-9284 because:
# 1, the provider user group is limited to authorized users, and it would not be possible
# for someone outside that group to callback.
# 2, there is no local session for the attacker to hijack.
#
# TODO: further investigation required.
#
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

JSON::JWK::Set::Fetcher.cache = Rails.cache

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :azure_ad,
    ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID'),
    ENV.fetch('OMNIAUTH_AZURE_CLIENT_SECRET'),
    ENV.fetch('OMNIAUTH_AZURE_TENANT_ID')
  )
end
