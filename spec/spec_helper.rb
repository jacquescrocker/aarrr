require 'bundler/setup'
require 'aarrr'

RSpec.configure do |c|

  c.before(:all) do
    # setup the AARRR test database
    AARRR.configure do |c|
      puts "configured to use aarrr_metrics_test db"
      c.database_name = "aarrr_metrics_test"
    end
  end

  # add helper methods here

end

