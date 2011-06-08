require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rack'

module AARRR
  describe Session do

    describe "#new" do
      it "should create a session with no data" do
        session = Session.new
        AARRR.users.count.should eq(1)
      end

      it "should create a session with a request env" do
        session = Session.new
        Session.new({
          "HTTP_COOKIE" => "_utmarr=#{session.id}; path=/;"
        })
        AARRR.users.count.should eq(1)

        session = Session.new({
          "HTTP_COOKIE" => "_utmarr=x83y1; path=/;"
        })

        AARRR.users.count.should eq(2)
      end
    end

    describe "tracking" do
      before(:each) do
        @session = Session.new
      end

      it "should track a custom event" do
        @session.track!(:something)

        AARRR.events.count.should eq(1)
      end
    end

    describe "saving" do
      it "should save the session to cookie" do
        @session = Session.new
        @session.track!(:some_event)

        # save session to response
        response = Rack::Response.new "some body", 200, {}
        @session.set_cookie(response)

        response.header["Set-Cookie"].should include("_utmarr=#{@session.id}")
      end
    end

  end
end