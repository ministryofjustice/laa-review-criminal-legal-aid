require_relative 'boot'

require 'rails'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require 'rails/test_unit/railtie'

require_relative '../app/lib/notify_mailer_interceptor'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaReviewCriminalLegalAid
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.force_ssl = true
    config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ /health|ping/ } } }

    # Load the templates set (refer to `config/govuk_notify_templates.yml` for details)
    config.govuk_notify_templates = config_for(
      :govuk_notify_templates, env: :production
    ).with_indifferent_access

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Authentication, authorization, and session configuration

    # The maximum time since a users was last authenticated on DOM1 before
    # they are automatically signed out.
    config.x.auth.reauthenticate_in = 12.hours

    # The maximum period of inactivity before a user is
    # automatically signed out.
    config.x.auth.timeout_in = 15.minutes
  end
end
