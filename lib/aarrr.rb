# encoding: utf-8

require "mongo"
require "aarrr/config"
require "aarrr/session"

require "rack"
require "aarrr/middleware"

# add railtie
if defined?(Rails)
  require "aarrr/railtie"
end

# helper method to initialize an AARRR session
def AARRR(env_or_model, attributes = nil)
  if env_or_model.is_a?(Hash) and env_or_model["aarrr.session"]
    env_or_model["aarrr.session"]
  else
    session = AARRR::Session.new(env_or_model, attributes)

    # add to the rack env (if applicable)
    env_or_model["aarrr.session"] = session if env_or_model.is_a?(Hash)

    session
  end

end

module AARRR

  class << self

    # Sets the Mongoid configuration options. Best used by passing a block.
    #
    # @example Set up configuration options.
    #
    #   AARRR.configure do |config|
    #     config.database = Mongo::Connection.new.db("metrics")
    #   end
    #
    # @return [ Config ] The configuration obejct.
    def configure
      config = AARRR::Config
      block_given? ? yield(config) : config
    end
    alias :config :configure
  end

  # Take all the public instance methods from the Config singleton and allow
  # them to be accessed through the AARRR module directly.
  #
  # @example Delegate the configuration methods.
  #   AARRR.database = Mongo::Connection.new.db("test")
  AARRR::Config.public_instance_methods(false).each do |name|
    (class << self; self; end).class_eval <<-EOT
      def #{name}(*args)
        configure.send("#{name}", *args)
      end
    EOT
  end

end