module Assigning
  %w[event command].each do |sub_dir|
    require File.expand_path("assigning/#{sub_dir}.rb", __dir__)

    Dir[File.expand_path("assigning/#{sub_dir}s/*.rb", __dir__)].each { |f| require f }
  end

  require_relative 'assigning/errors'
  require_relative 'assigning/assignment'
end
