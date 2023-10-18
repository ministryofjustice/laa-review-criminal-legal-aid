require 'laa_crime_schemas'

class CrimeApplicationPresenter
  attr_reader :crime_application

  # Rails helper method
  delegate_missing_to :@crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  def legacy_application?
    crime_application&.is_first_court_hearing&.blank?
  end

  def first_court_hearing?
    crime_application.is_first_court_hearing == LaaCrimeSchemas::Types::FirstHearingAnswerValues['yes']
  end

  def not_first_court_hearing?
    crime_application.is_first_court_hearing == LaaCrimeSchemas::Types::FirstHearingAnswerValues['no']
  end

  def no_hearing_yet?
    crime_application.is_first_court_hearing == LaaCrimeSchemas::Types::FirstHearingAnswerValues['no_hearing_yet']
  end

  # def using_first_court_hearing_name?
  #   (crime_application.is_first_court_hearing == LaaCrimeSchemas::Types::FirstHearingAnswerValues['no']) &&
  #     crime_application.first_court_hearing_name.present?
  # end
end
