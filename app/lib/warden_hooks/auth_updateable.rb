module WardenHooks
  # On sign-in, record last_auth_at and set the user's name and email
  # using the details in the OmniAuth auth_hash.
  #
  # Additionally, if the user is pending activation, set the first_auth_at
  # and the auth_subject_id.
  #
  # This code block is only triggered when the user is explicitly set (with set_user)
  # and during authentication. Retrieving the user from session (:fetch) will not trigger it.

  module AuthUpdateable
    Warden::Manager.after_set_user except: :fetch do |user, warden, options|
      user.update_from_auth_hash!(warden) if user && warden.authenticated?(options[:scope])
    end
  end
end
