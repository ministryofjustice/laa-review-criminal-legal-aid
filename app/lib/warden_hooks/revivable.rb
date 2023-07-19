module WardenHooks
  module Revivable
    Warden::Manager.after_set_user except: :fetch do |user, _warden, _options|
      Authorising::Revive.new(user: user, user_manager_id: user.id).call if user.revive_until.present?
    end
  end
end
