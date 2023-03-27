module Users
  class SessionsController < Devise::SessionsController
    private

    # Override Devise flash messages for now.
    def set_flash_message(_, _, _options = {}); end
  end
end
