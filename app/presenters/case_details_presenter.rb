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

  def client_remanded?
    (is_client_remanded == 'yes') && date_client_remanded.present?
  end

  private

  def type_of(value)
    LaaCrimeSchemas::Types::FirstHearingAnswerValues[value]
  end
end
