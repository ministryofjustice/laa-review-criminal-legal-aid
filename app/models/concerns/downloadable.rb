module Downloadable
  extend ActiveSupport::Concern

  def source_csv_file_count
    Rational(total_count, source_csv_limit).ceil
  end

  def source_csv_limit
    self.class::SOURCE_CSV_LIMIT
  end

  def source_csv_pagination(file: 1)
    { page: file, per_page: source_csv_limit }
  end

  def source_dataset(file: 1)
    paginated_response(http_client.post(
                         '/searches',
                         search: filter.datastore_params,
                         pagination: source_csv_pagination(file:)
                       ))
  end

  def source_csv(file: 1)
    ds = source_dataset(file:)
    @total_count ||= ds.pagination['total_count']

    CSV.generate do |csv|
      csv << ds.first.keys

      ds.each do |d|
        csv << d.values
      end
    end
  end
end
