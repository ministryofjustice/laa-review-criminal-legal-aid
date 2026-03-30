module Reporting
  class UserTemporalReportsController < Reporting::TemporalReportsController
    include ApplicationSearchable

    before_action :set_user_id

    def show
      @user = User.find_by(id: @user_id)
      filter_ids = @report.rows.presence || [SecureRandom.uuid]
      set_search(default_filter: { application_id_in: filter_ids })
    end

    private

    def extra_report_params
      { user_id: params[:user_id] }
    end

    def set_user_id
      @user_id = params[:user_id]
    end
  end
end
