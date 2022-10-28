require 'azure_ad_auth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_ad_auth,
   ENV['OMNIAUTH_AZURE_CLIENT_ID'],
   ENV['OMNIAUTH_AZURE_CLIENT_SECRET']
end
