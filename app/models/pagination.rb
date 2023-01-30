class Pagination < ApplicationStruct
  attribute :current_page, Types::Params::Integer.optional.default(1)
  attribute? :limit_value, Types::Params::Integer.default(50)
  attribute? :total_pages, Types::Params::Integer
  attribute? :total_count, Types::Params::Integer

  def datastore_params
    {
      page: current_page,
      per_page: limit_value
    }
  end
end
