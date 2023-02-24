module Reporting
  #
  # ReceivedOnReport keeps a count of the applications received (#total_received)
  # on a given BusinessDay, as well as the number of those applications that
  # have since been closed (#total_closed).
  #
  # It uses BusinessDay#date (#business_day) as its primary key.
  #
  # It is used as the basis for the WorkloadReport.
  #
  # ReceivedOnReport is a CQRS read model configured by the
  # ReceivedOnReports::Configuration
  #

  class ReceivedOnReport < ApplicationRecord
    def total_open
      total_received - total_closed
    end

    def readonly?
      true
    end
  end
end
