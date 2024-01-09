# Parse the settings.yml file and erb by a given scope and return it as config.
#
#   Configuration.new(scope: 'host_env_settings')
#
class Configuration
  def initialize(scope:, settings_file: nil)
    @scope = scope
    @settings_file = settings_file || app_settings_file
  end

  def config
    @config ||= config_hash.with_indifferent_access.freeze
  end

  private

  def config_hash
    YAML.load(config_yaml).fetch(scope, {})
  end

  def config_yaml
    ERB.new(settings_file.read).result
  end

  attr_reader :settings_file, :scope

  def app_settings_file
    Rails.root.join('config/settings.yml')
  end
end
