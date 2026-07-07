Rails.autoloaders.main.collapse(
  "#{Rails.root}/app/aggregates/*/events",
  "#{Rails.root}/app/aggregates/*/commands"
)

# Map specific underscore paths to their correct constant names where the
# default camelization would produce the wrong result (e.g. "govuk" -> "Govuk"
# rather than "GOVUK").
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'govuk_design_system_form_builder' => 'GOVUKDesignSystemFormBuilder'
  )
end
