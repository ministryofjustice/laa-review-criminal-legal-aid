require 'settings'
Govuk::Components.configure do |conf|
  conf.default_header_homepage_url = 'https://www.gov.uk'
  conf.default_header_service_name = 'Review criminal legal aid applications'
  conf.default_phase_banner_tag = Settings.phase_banner_tag
  conf.default_tag_colour = Settings.default_tag_colour
end
