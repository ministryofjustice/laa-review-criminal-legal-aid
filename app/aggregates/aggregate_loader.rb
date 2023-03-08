module AggregateLoader
  # TODO: review depature from rails/zeitwork for aggregates.
  def load_module_files(module_name, aggregate_name)
    %w[event command].each do |sub_dir|
      require File.expand_path("#{module_name}/#{sub_dir}.rb", __dir__)

      Dir[File.expand_path("#{module_name}/#{sub_dir}s/*.rb", __dir__)].each { |f| require f }
    end

    require_relative "#{module_name}/errors"
    require_relative "#{module_name}/#{aggregate_name}"
  end
end
