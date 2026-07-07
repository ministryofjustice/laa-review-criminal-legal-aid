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
end
