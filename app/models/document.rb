require 'laa_crime_schemas'

class Document < LaaCrimeSchemas::Structs::Document
  VIEWABLE_CONTENT_TYPES = [
    'application/pdf',
    'image/bmp',
    'image/jpeg',
    'image/png'
  ].freeze

  def file_extension
    File.extname(filename).delete_prefix('.')
  end

  def viewable_inline?
    VIEWABLE_CONTENT_TYPES.include?(content_type)
  end
end
