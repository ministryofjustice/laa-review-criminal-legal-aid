module CaseworkHelper
  def application_start_path(app)
    return history_crime_application_path(app) if app.parent_id.present? &&
                                                  app.application_type != 'post_submission_evidence'

    crime_application_path(app)
  end
end
