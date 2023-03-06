module Admin
  class ManageUsersController < ApplicationController
    def index
      if current_user.can_manage_others
        @users = User.all
      else
        flash[:important] = :cannot_access

        redirect_to assigned_applications_path
      end
    end
  end
end
