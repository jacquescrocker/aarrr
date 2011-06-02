require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module AARRR
  describe Session do

    describe "#new" do
      it "should create a session with no data" do
        session = Session.new
        AARRR.users.count.should eq(1)
      end

      it "should create a session with a request env" do
        session = Session.new
        AARRR.users.count.should eq(1)

        Session.new({
          "rack.request.cookie_hash" => {
            "_utmarr" => session.id
          }
        })
        AARRR.users.count.should eq(1)

        session = Session.new({
          "rack.request.cookie_hash" => {
            "_utmarr" => "x9x9x19x"
          }
        })

        AARRR.users.count.should eq(2)
      end
    end

  end
end