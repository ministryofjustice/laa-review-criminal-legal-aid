module ApiResource
  NotFound = Class.new(StandardError)

  def self.included(base)
    base.extend(QueryMethods)
  end

  def to_param
    id
  end

  module QueryMethods
    def open
      resources = DatastoreApi::Requests::ListApplications.new(
        status: :submitted
      ).call

      resources.map { |resource| new(resource) }
    end

    def closed
      # TODO: update when other 'closed' statuses are avaliable
      resources = DatastoreApi::Requests::ListApplications.new(
        status: :returned
      ).call

      resources.map { |resource| new(resource) }
    end

    def find(id)
      resource = DatastoreApi::Requests::GetApplication.new(
        application_id: id
      ).call

      new(resource)
    end
  end
end
