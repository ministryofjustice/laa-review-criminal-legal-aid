module WardenHooks
  # Each time a user is set, check to see if the time allowed between
  # authentications has been exceded. If it has, the user is signed out.
  #
  # User#last_auth_at is set by UserAuthenticate#authenticate!
  #
  module Reauthable
    Warden::Manager.after_set_user do |user, warden, options|
      scope = options[:scope]

      if user && warden.authenticated?(scope)
        proxy = Devise::Hooks::Proxy.new(warden)

        if user.auth_expired?
          Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)

          throw :warden, scope: scope, message: :reauthenticate
        end
      end
    end
  end
end
