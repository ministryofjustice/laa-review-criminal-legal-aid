module ApiResource
  NotFound = Class.new(StandardError)

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
      resource = ApiClient.new.find(id)

      raise NotFound unless resource

      new(resource)
    end
  end
end
