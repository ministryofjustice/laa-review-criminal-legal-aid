# aggegates and read_models are loaded by the initializers
Rails.autoloaders.main.ignore(
  Rails.root.join("app/aggregates"),
  Rails.root.join("app/read_models")
)
