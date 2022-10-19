class CrimeApplication < ApiResource
  attribute :id, Types::String
  attribute :laa_reference, Types::String
  attribute :applicant_name, Types::String
  attribute :received_at, Types::JSON::DateTime

  def to_param
    id
  end

  class << self
    # TOOD: find a better home
    #
    def extract_from_source(source)
      applicant_name = [
        source.dig('client_details', 'client', 'first_name'),
        source.dig('client_details', 'client', 'last_name')
      ].join(' ')

      {
        id: source['id'],
        applicant_name: applicant_name,
        laa_reference: source['application_reference'],
        received_at: source['application_start_date']
      }
    end
  end
end
