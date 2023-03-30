module Users
  class SessionsController < Devise::SessionsController
    layout 'external'
  end
end
