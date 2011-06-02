require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "spec setup" do
  it "should run the specs without error" do
    true.should be_true
  end
end

describe "AARRR()" do

  context "with an request.env" do
    before(:each) do
      @env = {}
      AARRR(@env)
    end

    it "should create a session" do
      AARRR.users.count.should eq(1)
    end

    it "should set the rack.aarrr env variable" do
      user_attributes = AARRR.users.find_one
      @env["rack.aarrr"].id.should eq(user_attributes["_id"])
    end
  end

end