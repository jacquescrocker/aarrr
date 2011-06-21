# encoding: utf-8

module AARRR

  # Configures AARRR
  module Config
    extend self
    @settings = {}

    @database = nil
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
        @settings.has_key?(name) ? @settings[name] : options[:default]
      end
      define_method("#{name}=") { |value| @settings[name] = value }
      define_method("#{name}?") { send(name) }
    end

    # default some options with defaults
    option :database_name, :default => "metrics"
    option :cookie_name, :default => "_utmarr"
    option :cookie_expiration, :default => 60*24*60*60
    option :user_collection_name, :default => "aarrr_users"
    option :event_collection_name, :default => "aarrr_events"
    option :suppress_errors, :default => false

    # set default client
    option :default_client, :default => "web"

    # match clients
    option :client_matchers, :default => {}

    # add a client matcher
    def match_client(client_name, matcher = nil)
      if matcher
        client_matchers[client_name.to_s] = matcher
      end
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

    def users
      database[user_collection_name]
    end

    def events
      database[event_collection_name]
    end

  end

end