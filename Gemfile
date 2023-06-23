source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.3'

gem 'business'
gem 'faraday'
gem 'govuk-components', '~> 4.0.0'
gem 'govuk_design_system_formbuilder', '~> 4.0.0'

gem 'govuk_notify_rails'

gem 'kaminari', '~> 1.2'

gem 'lograge'
gem 'logstash-event'

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas', tag: 'v0.4.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
gem 'turbo-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dartsass-rails', '~> 0.4.0'

# Exceptions notifications
gem 'sentry-rails'
gem 'sentry-ruby'

gem 'dry-schema'
gem 'dry-struct'

gem 'devise'
gem 'omniauth_openid_connect', '0.7.1'
gem 'omniauth-rails_csrf_protection'

gem 'aws-sdk-sns', '~> 1.60', require: false

gem 'aggregate_root'
gem 'rails_event_store'

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'axe-core-rspec'
  gem 'brakeman'
  gem 'capybara'
  gem 'erb_lint', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
  gem 'webmock'
end
