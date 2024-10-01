class DateStampContextPresenter < BasePresenter
  def initialize(date_stamp_context)
    super(
      @date_stamp_context = date_stamp_context
    )

    @applicant = date_stamp_context.applicant
  end

  def show?
    first_name_changed? || last_name_changed? || date_of_birth_changed?
  end

  def first_name_changed?
    return false unless @applicant

    @applicant.first_name != @date_stamp_context.first_name
  end

  def last_name_changed?
    return false unless @applicant

    @applicant.last_name != @date_stamp_context.last_name
  end

  def date_of_birth_changed?
    return false unless @applicant

    @applicant.date_of_birth != @date_stamp_context.date_of_birth
  end
end
