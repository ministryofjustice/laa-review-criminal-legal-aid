module MojPatternLibraryHelper
  def have_primary_navigation
    within('.govuk-notification-banner') do
      assertion = have_css('h2', text: title_text)
                  .and(have_css('div', text:))

      if details
        assertion.and(have_css('p', text: details))
      else
        assertion
      end
    end
  end
end
