ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder.configure do |conf|
  conf.default_submit_button_text   = 'Save and continue'
end

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  require 'form_builder_helper'
  include FormBuilderHelper
end
