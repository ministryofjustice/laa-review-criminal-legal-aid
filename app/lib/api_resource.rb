module ApiResource
  def self.included(base)
    base.extend(QueryMethods)
  end

  def to_param
    id
  end

  module QueryMethods
    # Override if transformation required
    #
    def params_from_source(source)
      source
    end

    def all
      @all ||= ApiClient.new.all.map do |json|
        new params_from_source(json)
      end
    end

    def find(id)
      json = ApiClient.new.find(id)

      new params_from_source(json)
    end
  end
end
