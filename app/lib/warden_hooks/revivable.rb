module WardenHooks
  module Revivable
    Warden::Manager.after_set_user except: :fetch do |user, _warden, _options|
      Authorising::Revive.new(user:).call if user
    end
  end
end
