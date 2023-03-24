Devise.setup do |config|
  require 'devise/orm/active_record'

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:none]

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = 5.minutes

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/auth'

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  config.omniauth :openid_connect, 
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
      issuer: "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_AZURE_TENANT_ID', nil)}/v2.0"
    }
end

Rails.application.config.to_prepare do
  Rails.application.reload_routes!

  Devise::SessionsController.layout "external"
end
