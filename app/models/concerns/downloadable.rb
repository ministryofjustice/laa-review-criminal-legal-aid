module Downloadable
  extend ActiveSupport::Concern

  def csv_limit
    self.class::CSV_LIMIT
  end

  def csv_pagination(file: 1)
    { page: file, per_page: csv_limit }
  end

  def csv_file_count
    Rational(total_count, csv_limit).ceil
  end

  def csv_dataset(file: 1)
    paginated_response(http_client.post(
                         '/searches',
                         search: filter.datastore_params,
                         pagination: csv_pagination(file:)
                       ))
  end

  def csv(file: 1)
    ds = csv_dataset(file:)
    @total_count ||= ds.pagination['total_count']

    CSV.generate do |csv|
      csv << ds.first.keys

      ds.each do |d|
        csv << d.values
      end
    end
  end
end
