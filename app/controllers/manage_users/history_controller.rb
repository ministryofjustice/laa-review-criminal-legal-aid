module ManageUsers
  class HistoryController < ManageUsers::BaseController
    def show
      @user = User.find(params[:id])
    end
  end
end
