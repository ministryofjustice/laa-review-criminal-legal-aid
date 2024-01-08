Govuk::Components.configure do |conf|
  conf.default_header_service_name = "Apply for a Juggling Licence"
  conf.default_phase_banner_text = "This is a new service – your feedback will help us to improve it."
  conf.default_phase_banner_tag = I18n.t('phase_banner.tag.local')
  conf.default_tag_colour = "orange"
end