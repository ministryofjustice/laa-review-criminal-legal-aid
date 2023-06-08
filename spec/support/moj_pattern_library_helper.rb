module MojPatternLibraryHelper
  def have_primary_navigation
    within('.govuk-notification-banner') do
      assertion = have_selector('h2', text: title_text)
                  .and(have_selector('div', text:))

      if details
        assertion.and(have_selector('p', text: details))
      else
        assertion
      end
    end
  end
end
