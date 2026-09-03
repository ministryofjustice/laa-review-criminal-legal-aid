module ProviderDataApi
  class RecordNotFound < StandardError; end

  class Office < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :addressLine1, Types::String.optional
    attribute? :addressLine2, Types::String.optional
    attribute? :addressLine3, Types::String.optional
    attribute? :addressLine4, Types::String.optional
    attribute? :city, Types::String.optional
    attribute? :county, Types::String.optional
    attribute? :postCode, Types::String.optional
  end

  class Firm < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :firmName, Types::String.optional
  end

  class OfficeDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute :office, Office
    attribute :firm, Firm
  end
end
