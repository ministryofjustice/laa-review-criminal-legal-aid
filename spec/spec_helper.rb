ENV['RAILS_ENV'] ||= 'test'

require 'webmock/rspec'

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'

  SimpleCov.start 'rails' do
    # Only track line coverage in parallel workers - branch coverage merging has issues
    if ENV['CI_NODE_INDEX']
      enable_coverage :line
    else
      enable_coverage :branch
    end
    coverage_criterion :line

    # Only enforce minimum coverage when merging all parallel results
    minimum_coverage 100 unless ENV['CI_NODE_INDEX']

    # TODO:  unfilter app/views once fix by simplecov team implemented
    add_filter 'app/views'
    add_filter 'app/components' # ERB view components cause line count issues
    add_filter 'app/mailers/application_mailer.rb'
    add_filter 'app/jobs/application_job.rb'
    add_filter 'config/initializers'
    add_filter 'lib/rubocop/'
    add_filter 'spec/'

    enable_coverage_for_eval

    # Support for parallel CI runs - each runner saves results with unique ID
    command_name "rspec-node-#{ENV['CI_NODE_INDEX'] || 0}" if ENV['CI']
  end

  # Eager load all app code AFTER SimpleCov starts for consistent tracking across parallel runners
  if ENV['CI_NODE_INDEX']
    require_relative '../config/environment'
    Rails.application.eager_load!
  end
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

def expect_forbidden
  heading_text = page.first('.govuk-heading-xl').text

  expect(heading_text).to eq('Access to this service is restricted')
  expect(page).to have_http_status(:forbidden)
end
