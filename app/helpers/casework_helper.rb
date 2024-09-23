module CaseworkHelper
  def application_start_path(app)
    return history_crime_application_path(app) if app.parent_id.present? &&
                                                  app.application_type != 'post_submission_evidence'

    crime_application_path(app)
  end

  def history_item_link_text(application)
    return 'latest_application' if current_crime_application.id == application.id &&
                                   application.application_type != 'post_submission_evidence'

    'selected_application'
  end

  # TODO: can we distinguish between PSE and resubmitted applications more easily?
  # To identify first time submission events for applications that do not have versions
  # Post submission evidence applications are resubmissions under the hood
  def first_submission_event?(application)
    current_crime_application.id == application.id &&
      (application.parent_id.nil? || application.application_type == 'post_submission_evidence')
  end
end
