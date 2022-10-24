# TODO: share types via gem
module Types
  include Dry.Types()

  COURT_TYPES = %w[
    crown
    magistrates
  ].freeze

  OFFENCE_CLASSES = %w[
    a b c d e f g h i j k
  ].freeze

  CASE_TYPES = %w[
    summary_only
    either_way
    indictable
    already_in_crown_court
    commital
    appeal_to_crown_court
    appeal_to_crown_court_with_changes
  ].freeze

  CORRESPONDENCE_ADDRESS_TYPES = %w[
    other_address
    home_address
    provider_address
  ].freeze

  INTERESTS_OF_JUSTICE_TYPES = %w[
    liberty
    suspended_sentence
    livelihood
    reputation
    question_of_law
    unable_to_understand
    witnesses_needed
    expert_cross_examination
    interests_of_another
    ioj_other
  ].freeze

  CorrespondenceAddressType = String.enum(*CORRESPONDENCE_ADDRESS_TYPES)
  OffenceClass = String.enum(*OFFENCE_CLASSES)
  CaseType = String.enum(*CASE_TYPES)
  CourtType = String.enum(*COURT_TYPES)
  InterestsOfJusticeCriterion = String.enum(*INTERESTS_OF_JUSTICE_TYPES)

  CrimeApplicationReference = Types::String
  Uuid = String
  PhoneNumber = String
  Date = Date | JSON::Date
end
