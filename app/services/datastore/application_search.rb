module Datastore
  # Lightweight wrapper around the Datastore search API.
  #
  # Uses the /searches endpoint which returns a smaller subset of
  # application data compared to GetApplication, making it more
  # efficient for bulk lookups (e.g. the review_reference_backfill rake task).
  #
  class ApplicationSearch
    include DatastoreApi::Traits::ApiRequest
    include DatastoreApi::Traits::PaginatedResponse

    def by_application_ids(application_ids)
      paginated_response(
        http_client.post('/searches', search: { application_id_in: application_ids },
                                      pagination: { per_page: application_ids.size, page: 1 })
      )
    end

    def reference_for_application_id(application_id)
      paginated_response(
        http_client.post('/searches', search: { application_id_in: [application_id] },
                                      pagination: { per_page: 1, page: 1 })
      ).first&.fetch('reference', nil)
    end
  end
end
