require 'laa_crime_schemas'

class PropertiesPresenter < BasePresenter
  OTHER = 'other'.freeze
  RESIDENTIAL = 'residential'.freeze
  COMMERCIAL = 'commercial'.freeze
  LAND = 'land'.freeze

  PROPERTY_TYPE_MAPPING = {
    residential: { display_name: 'property' },
    commercial: { display_name: 'property' },
    land: { display_name: 'land' }
  }.freeze
end
