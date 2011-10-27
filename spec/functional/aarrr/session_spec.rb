require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rack'

module AARRR
  describe Session do

    describe "#new" do
      it "should create a session with no data" do
        session = Session.new
        AARRR.users.count.should eq(1)
      end
      
      it "should load a session from a string id" do
        session = Session.new
        from_id = Session.new(session.id)
        from_id.user.should_not be_nil
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
      
      it "should set the created date" do
        just_now = Time.new.getutc - 10
        session = Session.new
        pp session.created_date
        session.created_date.should be >= just_now
      end
      
      it "should not change the created date when re-loading" do
        session = Session.new        
        second_session = Session.new(session.id)
        session.created_date.should eql second_session.created_date
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
        @session.save(response)

        response.header["Set-Cookie"].should include("_utmarr=#{@session.id}")
      end
    end

  end
end