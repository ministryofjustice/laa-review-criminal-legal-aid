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
      response = DatastoreApi::Requests::ListApplications.new(
        status: :submitted
      ).call

      response.map { |data| new(data) }
    end

    def find(id)
      resource = DatastoreApi::Requests::GetApplication.new(
        application_id: id
      ).call

      raise NotFound unless resource

      new(resource)
    end
  end
end
