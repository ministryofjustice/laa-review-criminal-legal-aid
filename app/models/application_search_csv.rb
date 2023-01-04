require 'csv'

class ApplicationSearchCsv
  def initialize(filter:)
    @filter = filter
  end

  def csv
    @csv ||= CSV.generate do |csv|
      csv << headers

      search.each do |result|
        csv << ApplicationSearchResult.new(result).as_csv
      end
    end
  end

  def file_name
    "application_search-#{@filter.state_key}.csv"
  end

  private

  def headers
    %i[reference received_on reviewed_on caseworker status].map do |key|
      I18n.t(key, scope: :table_headings)
    end
  end

  def search
    @search ||= DatastoreApi::Requests::SearchApplications.new(
      **@filter.as_json, per_page: 10_000
    ).call
  end
end
