require 'laa_crime_schemas'

class Document < LaaCrimeSchemas::Structs::Document
  def file_type
    File.extname(filename).delete_prefix('.')
  end
end
