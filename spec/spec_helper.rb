require 'bundler/setup'
require 'aarrr'
require 'rack/test'

RSpec.configure do |config|

  config.before(:suite) do
    # setup the AARRR test database
    AARRR.configure do |c|
      puts "configured to use aarrr_metrics_test db"
      c.database_name = "aarrr_metrics_test"
    end
  end

  config.before(:each) do
    AARRR.database.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end

  config.include(Rack::Test::Methods)

  # add helper methods here

end

