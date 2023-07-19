module WardenHooks
  module Revivable
    Warden::Manager.after_set_user except: :fetch do |user, _warden, _options|
      if user.revive_until.present?
        Authorising::Revive.new(user: user, user_manager_id: user.id).call
      end
    end
  end
end
