# FlashNotice view object
#
# Takes a flash item and converts it into a view object with attributes
# matching those used by the govuk_notification_banner helper

class FlashNotice
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::UrlHelper

  def initialize(key, message)
    content = Array[*message]

    @text = content.delete_at(0)
    @key = key
    @raw_details = content
  end

  attr_reader :text

  def details
    @details ||= @raw_details.map do |raw_detail|
      # Remove all tags and replace placeholder with link
      strip_tags(raw_detail).sub('ONBOARDING_EMAIL_LINK', onboarding_email_link)
    end
  end

  def success?
    %i[success notice].include? key.to_sym
  end

  def title_text
    I18n.t(:title, scope: "flash.#{key}")
  end

  def to_partial_path
    'flash_notice'
  end

  private

  attr_reader :key

  def onboarding_email_link
    mail_to(Rails.application.config.x.admin.onboarding_email)
  end
end
