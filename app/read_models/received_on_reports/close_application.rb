module ReceivedOnReports
  class CloseApplication < Handler
    def store_event!
      Reporting::ReceivedOnReport.increment_counter :total_closed, business_day
    end
  end
end
