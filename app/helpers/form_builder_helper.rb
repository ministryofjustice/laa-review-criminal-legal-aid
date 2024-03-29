# This module gets mixed in and extends the helpers already provided by
# `GOVUKDesignSystemFormBuilder::FormBuilder`. These are app-specific
# form helpers so can be coupled to application business and logic.
#
module FormBuilderHelper
  def search_date_field(attribute_name, **kwargs, &block)
    GOVUKDesignSystemFormBuilder::Elements::Inputs::SearchDate.new(
      self, object_name, attribute_name,
      hint: {}, label: {}, caption: {}, width: nil, form_group: {}, prefix_text: nil, suffix_text: nil,
      extra_letter_spacing: false, **kwargs, &block
    ).html
  end

  def continue_button
    submit_button(:save_and_continue) do
      submit_button(:save_and_come_back_later, secondary: true, name: 'commit_draft') if show_secondary_button?
    end
  end

  private

  # The `save and come back later` might not always be needed,
  # this method can have logic for show/hide.
  # :nocov:
  def show_secondary_button?
    true
  end
  # :nocov:

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
  end
end

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
