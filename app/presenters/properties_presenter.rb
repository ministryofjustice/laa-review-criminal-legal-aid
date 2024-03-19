require 'laa_crime_schemas'

class PropertiesPresenter < BasePresenter
  PROPERTY_TYPE_MAPPING = {
    'residential' => { display_name: 'property' },
    'commercial' => { display_name: 'property' },
    'land' => { display_name: 'land' }
  }.freeze

  def initialize(properties)
    super(
      @properties = properties
    )
  end
end
