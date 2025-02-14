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

    # [CRIMAPP-1647] An application may only be determined as NAFI
    # during the process of being added to MAAT. The MAAT API
    # will hopefully be updated to include the `review_type` of
    # the latest means assessment. As a temporary workaround,
    # we check for the presence of the string "NAFI" in the `ioj_reason`.
    def nafi?
      ioj_reason.present? && !!ioj_reason['NAFI']
    end
  end
end
