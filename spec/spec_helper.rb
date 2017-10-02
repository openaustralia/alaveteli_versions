# frozen_string_literal: true

require_relative('../scraper')
require 'pry'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.shared_context 'ScraperWiki' do
  before(:each) do
    # Create a new connection to new sqlite
    ScraperWiki.close_sqlite
    ScraperWiki.config = { db: ':memory:' }
    ScraperWiki.sqlite_magic_connection.execute('PRAGMA database_list')
  end

  after(:each) do
    # Reset sqlite connection
    ScraperWiki.close_sqlite
    ScraperWiki.instance_variable_set(:@config, nil)
    ScraperWiki.instance_variable_set(:@sqlite_magic_connection, nil)
  end
end
RSpec.configure do |config|
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true
  # Set up a clean database for every test
  config.include_context 'ScraperWiki'
end

def puts(*args); end
