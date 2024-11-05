source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '>= 7.1.3.1'

gem 'business'
gem 'faraday'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'

gem 'govuk_notify_rails'

gem 'kaminari'

gem 'lograge'
gem 'logstash-event'

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client',
    tag: 'v1.2.1',
    require: 'datastore_api'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas',
    tag: 'v1.4.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails', '>= 2.0.0'
gem 'turbo-rails', '>= 2.0.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dartsass-rails', '~> 0.5.0'

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
gem 'rails_event_store'

# Monitoring
gem 'prometheus_exporter'

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'pry'
  gem 'rspec-rails', '>= 6.1.3'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'axe-core-rspec'
  gem 'brakeman'
  gem 'capybara', '>= 3.40.0'
  gem 'erb_lint', require: false
  gem 'rubocop', '>= 1.65.0', require: false
  gem 'rubocop-performance', '>= 1.21.1', require: false
  gem 'rubocop-rails', '>= 2.26.0', require: false
  gem 'rubocop-rspec', '>= 3.0.3', require: false
  gem 'selenium-webdriver', '>= 4.22.0'
  gem 'simplecov', require: false
  gem 'webmock', '>= 3.20.0'
end
