require_relative 'aggregate_loader'

module Reviewing
  extend AggregateLoader

  load_module_files('reviewing', 'review')
end
