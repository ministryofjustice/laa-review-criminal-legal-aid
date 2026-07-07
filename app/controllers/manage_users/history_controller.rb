module ManageUsers
  class HistoryController < ManageUsers::BaseController
    def show
      @user = User.find(params.expect(:id))
    end
  end
end
