module TypeOfApplication
  extend ActiveSupport::Concern

  def pse?
    application_type == Types::ApplicationType['post_submission_evidence']
  end

  def cifc?
    application_type == Types::ApplicationType['change_in_financial_circumstances']
  end

  def initial?
    application_type == Types::ApplicationType['initial']
  end

  def non_means?
    work_stream == Types::WorkStreamType['non_means_tested']
  end

  def appeal_no_changes?
    case_details&.case_type == Types::CaseType['appeal_to_crown_court'] &&
      case_details&.appeal_reference_number.present?
  end
end
