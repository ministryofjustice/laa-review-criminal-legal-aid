module ReceivedOnReports
  class ReceiveApplication < Handler
    def store_event!
      Reporting::ReceivedOnReport.insert({ business_day: })
      Reporting::ReceivedOnReport.increment_counter :total_received, business_day
    end
  end
end