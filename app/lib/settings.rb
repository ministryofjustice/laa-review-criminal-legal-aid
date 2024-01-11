require 'configuration'
#
# Retrieve settings for the current HostEnv.
#
# usage (for e.g. `default_header_tag`):
#
#   Settings.default_header_tag
#
class Settings
  include Singleton

  attr_reader :config, :env_name

  def initialize
    @env_name = HostEnv.env_name
    @config = Configuration.new(scope: 'host_env_settings').config.freeze
  end

  class << self
    delegate :method_missing, :respond_to?, to: :instance
  end

  def method_missing(name, *args)
    super unless config.key?(name)

    config.fetch(name).fetch(env_name)
  end

  def respond_to_missing?(name, _include_private = false)
    config.key?(name) || super
  end
end
