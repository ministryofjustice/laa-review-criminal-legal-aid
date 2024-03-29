require 'settings'
Govuk::Components.configure do |conf|
  conf.default_header_service_name = "Review criminal legal aid applications"
  conf.default_phase_banner_text = "This is a new service – your feedback will help us to improve it."
  conf.default_phase_banner_tag = Settings.phase_banner_tag
  conf.default_tag_colour = Settings.default_tag_colour
end
