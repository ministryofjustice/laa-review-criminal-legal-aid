ENV['RAILS_ENV'] ||= 'test'

require 'webmock/rspec'
require 'simplecov'

SimpleCov.start 'rails' do
  enable_coverage :branch
  coverage_criterion :branch
  # primary_coverage :branch
  minimum_coverage 100
  # TODO:  unfilter app/views once fix by simplecov team implemented
  add_filter 'app/views'
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/jobs/application_job.rb'
  add_filter 'config/initializers'
  add_filter 'lib/rubocop/'
  add_filter 'spec/'

  enable_coverage_for_eval
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.profile_examples = true
end

def print_page
  require 'nokogiri'
  html = page.html
  doc = Nokogiri::HTML.parse(html)
  formatted_html = doc.to_xhtml(indent: 2)
  puts formatted_html
end
