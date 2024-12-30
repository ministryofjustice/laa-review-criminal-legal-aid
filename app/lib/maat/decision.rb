module Maat
  class Decision < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :maat_ref, Types::MaatId
    attribute? :usn, Types::ApplicationReference.optional
    attribute? :case_id, Types::String
    attribute? :case_type, Types::String
    attribute? :app_created_date, Types::DateTime.optional

    attribute? :ioj_result, Types::String.optional
    attribute? :ioj_reason, Types::String.optional
    attribute? :ioj_assessor_name, Types::String.optional

    attribute? :ioj_appeal_result, Types::String.optional

    attribute? :means_result, Types::String.optional
    attribute? :means_assessor_name, Types::String.optional
    attribute? :date_means_created, Types::DateTime.optional

    attribute? :passport_result, Types::String.optional
    attribute? :passport_assessor_name, Types::String.optional
    attribute? :date_passport_created, Types::DateTime.optional

    attribute? :funding_decision, Types::String.optional
    attribute? :cc_rep_decision, Types::String.optional
  end
end
