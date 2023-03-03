module Admin
  class ManageUsersController < ApplicationController
    def index
      @users = User.all
    end
  end
end
