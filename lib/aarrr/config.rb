# encoding: utf-8

module AARRR

  # Configures AARRR
  module Config
    extend self
    @settings = {}

    @database = nil
    @database_name = nil
    @connection = nil

    # Define a configuration option with a default.
    #
    # @example Define the option.
    #   Config.option(:persist_in_safe_mode, :default => false)
    #
    # @param [ Symbol ] name The name of the configuration option.
    # @param [ Hash ] options Extras for the option.
    #
    # @option options [ Object ] :default The default value.
    #
    def option(name, options = {})
      define_method(name) do
        settings.has_key?(name) ? settings[name] : options[:default]
      end
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}?") { send(name) }
    end

    def database_name
      @database_name || "metrics"
    end

    def database_name=(database_name)
      @database_name = database_name
    end

    # Get the Mongo::Connection to use to pull the AARRR metrics data
    def connection
      @connection || Mongo::Connection.new
    end

    # Set the Mongo::Connection to use to pull the AARRR metrics data
    def connection=(connection)
      @connection = connection
    end

    # Get the Mongo::Database associated with the AARRR metrics data
    def database
      @database || connection.db(database_name)
    end

    # Set the Mongo::Database associated with the AARRR metrics data
    def database=(database)
      @database = database
    end

  end

end