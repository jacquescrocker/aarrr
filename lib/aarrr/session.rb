# encoding: utf-8

require "active_support/core_ext/hash/indifferent_access"

module AARRR

  # an AARR session is used to identify a particular user in order to track events
  class Session
    attr_accessor :id

    # find or creates a session in the db based on the env or object
    def initialize(env_or_object = nil, attributes = nil)
      # if it's an object with an id, then return that
      if env_or_object.respond_to?(:id) and env_or_object.id.is_a?(BSON::ObjectId)
        user_id = env_or_object.id.to_s
        attributes = {"$set" => attributes || {}}
        AARRR.users.update({"user_id" => user_id}, attributes, :upsert => true, :safe => true)

        # set newly created id
        user = AARRR.users.find_one({"user_id" => user_id})
        self.id = user["_id"] if user.present?
      else
        # perform upsert to build object
        self.id = parse_id(env_or_object) || BSON::ObjectId.new.to_s

        attributes = {"$set" => build_attributes(env_or_object).merge(attributes || {})}
        AARRR.users.update({"_id" => id}, attributes, :upsert => true)
      end

    end

    # returns a reference the othe AARRR user
    def user
      AARRR.users.find_one('_id' => id)
    end

    # sets some additional data
    def set_data(data)
      update({"data" => {"$set" => data}})
    end

    # save a cookie to the response
    def set_cookie(response)
      response.set_cookie(AARRR::Config.cookie_name, {
        :value => self.id,
        :path => "/",
        :expires => Time.now+AARRR::Config.cookie_expiration
      })
    end

    # track event name
    def track!(event_name, options = {})
      options = options.with_indifferent_access

      # add event tracking
      result = AARRR.events.insert({
        "aarrr_user_id" => self.id,
        "event_name" => event_name.to_s,
        "event_type" => translate_event_type(options["event_type"]),
        "in_progress" => options["in_progress"] || false,
        "data" => options["data"],
        "revenue" => options["revenue"],
        "referral_code" => options["referral_code"],
        "client" => options["client"],
        "created_at" => options["created_at"] || Time.now.getutc
      })

      # update user with last updated time
      user_updates = {
        "last_event_at" => Time.now.getutc
      }
      user_updates["user_id"] = options["user_id"].to_s if options["user_id"]
      update({
        "$set" => user_updates
      })

      result
    end

    # more helpers

    def acquisition!(event_name, options = {})
      options[:event_type] = :acquisition
      track!(event_name, options)
    end

    def activation!(event_name, options = {})
      options[:event_type] = :activation
      track!(event_name, options)
    end

    def retention!(event_name, options = {})
      options[:event_type] = :retention
      track!(event_name, options)
    end

    # TODO: referral and revenue


    protected

    # expand event type
    def translate_event_type(event_type)
      event_type = event_type.to_s
      case event_type
      when "acq"
        "acquisition"
      when "act"
        "activation"
      when "ret"
        "retention"
      when "rev"
        "revenue"
      when "ref"
        "referral"
      else
        event_type
      end
    end

    # mark update
    def update(attributes, options = {})
      AARRR.users.update({"_id" => id}, attributes, options)
    end

    # returns id
    def parse_id(env_or_object)
      # check for empty case or string

      # if it's a hash, then process like a request and pull out the cookie
      if env_or_object.is_a?(Hash)
        if env_or_object["rack.session"].is_a?(Hash) and env_or_object["rack.session"]["user_id"]
          # lookup user_id
          user = AARRR.users.find_one({"user_id" => env_or_object["rack.session"]["user_id"].to_s})
          if user.present?
            if env_or_object["aarrr.id"]
              # TODO: convert aarrr.id items to attach to current user
            end

            user["_id"]
          end
        elsif env_or_object["aarrr.id"]
          env_or_object["aarrr.id"]
        else
          request = Rack::Request.new(env_or_object)
          request.cookies[AARRR::Config.cookie_name]
        end
      # if it's a string
      elsif env_or_object.is_a?(String)
        env_or_object

      end
    end

    # returns updates
    def build_attributes(env_or_object)
      if env_or_object.is_a?(Hash)
        user_attributes = {}

        # referrer: HTTP_REFERER
        referrer = env_or_object["HTTP_REFERER"]
        user_attributes["referrer"] = referrer if referrer

        # ip_address: HTTP_X_REAL_IP || REMOTE_ADDR
        ip_address = env_or_object["HTTP_X_REAL_IP"] || env_or_object["REMOTE_ADDR"]
        user_attributes["ip_address"] = ip_address if ip_address

        # set user_id if its in the session
        if env_or_object["rack.session"].is_a?(Hash) and env_or_object["rack.session"]["user_id"]
          user_attributes["user_id"] = env_or_object["rack.session"]["user_id"].to_s
        end

        user_attributes
      else
        {}
      end
    end

  end
end