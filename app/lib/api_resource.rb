module ApiResource
  def self.included(base)
    base.extend(QueryMethods)
  end

  def to_param
    id
  end

  module QueryMethods
    def all
      ApiClient.new.all.map { |data| new(data) }
    end

    def find(id)
      new(ApiClient.new.find(id))
    end
  end
end
