module GdsHelper
  def have_notification_banner(text:, details: nil, success: false)
    title_text = success ? 'Success' : 'Important'

    within('.govuk-notification-banner') do
      assertion = have_selector('h2', text: title_text)
                  .and(have_selector('div', text:))

      [details].flatten.each do |detail|
        assertion = assertion.and(have_selector('p', text: detail))
      end

      assertion
    end
  end

  def have_success_notification_banner(text:, details: nil)
    success = true
    have_notification_banner(text:, details:, success:)
  end
end
