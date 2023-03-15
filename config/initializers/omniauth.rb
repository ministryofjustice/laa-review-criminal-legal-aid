# 
# In response to CVE-2015-9284. OmniAuth was modified to only allow
# post requests by default. This app is not vulnerable to the attack
# described in CVE-2015-9284.
#
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

# used for caching Azure AD discovery
JSON::JWK::Set::Fetcher.cache = Rails.cache

tenant_id = ENV.fetch('OMNIAUTH_AZURE_TENANT_ID', nil)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :openid_connect, 
    {
      name: :azure_ad,
      scope: [:openid, :email, :profile],
      response_type: :code,
      client_options: {
        identifier: ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID', nil),
        secret: ENV.fetch('OMNIAUTH_AZURE_CLIENT_SECRET', nil)
      },
      discovery: true,
      pkce: true,
      issuer: "https://login.microsoftonline.com/#{tenant_id}/v2.0",
    }
  )
end

OmniAuth.config.logger = Rails.logger
