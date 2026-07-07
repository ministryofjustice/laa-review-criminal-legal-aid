module GOVUKDesignSystemFormBuilder
  module Elements
    module Inputs
      class SearchDate < Base
        include Traits::Input
        include Traits::Error
        include Traits::Hint
        include Traits::Label
        include Traits::Supplemental
        include Traits::HTMLAttributes

        private

        def builder_method
          :date_field
        end
      end
    end
  end
end
