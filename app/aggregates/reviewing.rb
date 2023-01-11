module Reviewing
  # TODO: review depature from rails/zeitwork for aggregates.
  %w[event command].each do |sub_dir|
    require File.expand_path("reviewing/#{sub_dir}.rb", __dir__)

    Dir[File.expand_path("reviewing/#{sub_dir}s/*.rb", __dir__)].each { |f| require f }
  end

  require_relative 'reviewing/errors'
  require_relative 'reviewing/review'
end
