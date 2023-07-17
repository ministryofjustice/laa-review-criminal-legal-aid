module Admin
  module ManageUsers
    class ReviveUsersController < ManageUsersController
      def new
        puts "REVIVE USERS CONTROLLER -> NEW"

        redirect_to :back
      end
    end
  end
end
