# encoding: utf-8

module AARRR

  # an AARR session is used to identify a particular user in order to track events
  class Session
    attr_accessor :id

    def initialize(env_or_object = nil)
      # find or creates a session in the db based on the env or object
      #
      # TODO
      #
      self.id = parse_id(env_or_object) || BSON::ObjectId.new.to_s
      AARRR.users.update({"_id" => id}, {"$set" => user_data(env_or_object)}, :upsert => true)
    end

    # returns a reference the othe AARRR user
    def user
      AARRR.users.find(id)
    end

    def set_data(data)
      AARRR.users.update({"_id" => id}, {"data" => {"$set" => data}})
    end

    protected

    # returns id
    def parse_id(env_or_object)
      # check for empty case or string

      # if it's a hash, then process like a request.env
      if env_or_object.is_a?(Hash)
        (env_or_object["rack.request.cookie_hash"] || {})[AARRR::Config.cookie_name]

      # if it's an object with an id, then return that
      elsif env_or_object.respond_to?(:id) and env_or_object.id.is_a?(BSON::ObjectId)
        env_or_object.id.to_s

      # if it's a string
      elsif env_or_object.is_a?(String)
        env_or_object

      end
    end

    # returns updates
    def user_data(env_or_object)
      if env_or_object.is_a?(Hash)
        user_data = {}

        # referrer: HTTP_REFERER
        referrer = env_or_object["HTTP_REFERER"]
        user_data["referrer"] = referrer if referrer

        # ip_address: HTTP_X_REAL_IP || REMOTE_ADDR
        ip_address = env_or_object["HTTP_X_REAL_IP"] || env_or_object["REMOTE_ADDR"]
        user_data["ip_address"] = ip_address if ip_address

        # TODO: additional data from the env for the user

        user_data
      else
        {}
      end
    end

  end
end