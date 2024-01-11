require 'configuration'
# Determine whether or not a feature is enabled in this environment.
#
# usage (for e.g. feature :foobar):
#
#   FeatureFlags.foobar.enabled?
#
class FeatureFlags
  include Singleton

  attr_reader :config, :env_name

  class EnabledFeature
    def initialize(config, env_name)
      @env_config = config
      @env_name = env_name
    end

    def enabled?
      @env_config.fetch(@env_name, false)
    end

    def disabled?
      !enabled?
    end
  end

  def initialize
    @env_name = HostEnv.env_name

    @config = Configuration.new(scope: 'feature_flags').config.freeze
  end

  class << self
    delegate :method_missing, :respond_to?, to: :instance
  end

  def method_missing(name, *args)
    super unless config.key?(name)

    EnabledFeature.new(config.fetch(name), env_name)
  end

  def respond_to_missing?(name, _include_private = false)
    config.key?(name) || super
  end
end
