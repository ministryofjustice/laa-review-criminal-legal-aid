module Reporting
  class CurrentWorkloadReportRow < ApplicationStruct
    attribute :business_day, Types::Date
    attribute :total_received, Types::Integer
    attribute :total_open, Types::Integer
  end
end
