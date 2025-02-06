source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails'

gem 'business'
gem 'faraday'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'

gem 'govuk_notify_rails', '>= 3.0.0'

gem 'kaminari'

gem 'lograge'
gem 'logstash-event'

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client',
    tag: 'v1.2.1',
    require: 'datastore_api'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas',
    tag: 'v1.7.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails', '>= 2.0.0'
gem 'turbo-rails', '>= 2.0.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dartsass-rails', '~> 0.5.1'

# Exceptions notifications
gem 'sentry-rails', '>= 5.15.1'
gem 'sentry-ruby'
gem 'stackprof'

gem 'dry-schema'
gem 'dry-struct'

gem 'devise'
gem 'omniauth_openid_connect', '0.8.0'
gem 'omniauth-rails_csrf_protection'

gem 'oauth2'

gem 'aws-sdk-sns', '~> 1.60', require: false

gem 'aggregate_root'
gem 'rails_event_store', '>= 2.15.0'

# Monitoring
gem 'prometheus_exporter'

group :development, :test do
  gem 'debug', '~> 1.10'
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'pry'
  gem 'rspec-rails', '>= 7.0.1'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'axe-core-rspec'
  gem 'brakeman'
  gem 'capybara'
  gem 'erb_lint', '>= 0.7.0', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end
