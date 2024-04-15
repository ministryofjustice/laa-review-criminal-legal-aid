require 'laa_crime_schemas'

class CaseDetailsPresenter < BasePresenter
  def first_court_hearing
    if legacy_application?
      t('values.not_asked')
    elsif no_hearing_yet?
      t('values.no_hearing_yet')
    else
      first_court_hearing_name
    end
  end

  def next_court_hearing
    hearing_court_name
  end

  def next_court_hearing_at
    l(hearing_date, format: :compact)
  end

  def legacy_application?
    is_first_court_hearing.blank?
  end

  def no_hearing_yet?
    is_first_court_hearing == type_of('no_hearing_yet')
  end

  def case_concluded?
    (has_case_concluded == 'yes') && date_case_concluded.present?
  end

  def preorder_work_claimed?
    (is_preorder_work_claimed == 'yes') && preorder_work_date.present? && preorder_work_details.present?
  end

  def client_remanded?
    (is_client_remanded == 'yes') && date_client_remanded.present?
  end

  def appeal?
    case_type&.include?('appeal')
  end

  def financial_circumstances_changed?
    appeal? && (appeal_financial_circumstances_changed == 'yes')
  end

  def original_app_submitted?
    appeal? && (appeal_original_app_submitted == 'yes')
  end

  private

  def type_of(value)
    LaaCrimeSchemas::Types::FirstHearingAnswerValues[value]
  end
end
