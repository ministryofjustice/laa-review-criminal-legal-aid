require 'omniauth/strategies/azure_ad'
require 'warden/strategies'

# 
# In response to CVE-2015-9284. OmniAuth was modified to only allow
# post requests by default. This app is not vulnerable to the attack
# described in CVE-2015-9284.
#
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

# used for caching Azure AD discovery
JSON::JWK::Set::Fetcher.cache = Rails.cache

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :azure_ad,
    ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID', nil),
    ENV.fetch('OMNIAUTH_AZURE_CLIENT_SECRET', nil),
    ENV.fetch('OMNIAUTH_AZURE_TENANT_ID', nil)
  )
end

OmniAuth.config.logger = Rails.logger
