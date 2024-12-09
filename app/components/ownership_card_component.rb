class OwnershipCardComponent < CardComponent
  # For items that have ownership/subject that needs to be displayed in the title.
  # The item must implement #ownership_type.

  def title
    safe_join([super, title_subject].compact)
  end

  private

  def title_subject
    return unless show_subject?

    ": #{t(item.ownership_type, scope: 'helpers.subjects')}"
  end

  def show_subject?
    helpers.current_crime_application.applicant.has_partner == 'yes'
  end
end
