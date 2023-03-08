require_relative './aggregate_loader'
module Assigning
  extend AggregateLoader

  load_module_files('assigning', 'assignment')
end
