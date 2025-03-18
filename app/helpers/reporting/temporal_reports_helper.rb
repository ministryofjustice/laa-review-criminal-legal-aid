module Reporting
  module TemporalReportsHelper
    def format_percentage(value)
      "#{value}%" if value
    end
  end
end
