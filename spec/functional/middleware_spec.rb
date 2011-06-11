require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'an app that includes the aarrr middleware' do
  def app
    app = Rack::Builder.app do

      use AARRR::Middleware
      run lambda { |env|
        [200, {'Content-Type' => 'text/plain'}, ["Hello"]]
      }
    end
  end

  it "includes the id in a cookie in the response" do
    response = Rack::MockRequest.new(app).get('/')
    user = AARRR.users.find_one
    response.headers['Set-Cookie'].should =~ /_utmarr=#{user["_id"]}; path=\//
  end

  context "when including with another middleware" do
    def app
      Rack::Builder.app do

        use Rack::Session::Cookie, :key    => 'rack.session',
                                   :secret => 'secret',
                                   :expire_after => 10000
        use AARRR::Middleware
        run lambda { |env|
          env['rack.session'] = {"user_id" => 'myid'}
          [200, {'Content-Type' => 'text/plain'}, []]
        }
      end
    end

    it "includes the session cookie in the response" do
      get '/'
      last_response.headers["Set-Cookie"].should =~ /rack\.session/
    end

    it "includes the aarrr cookie in the response" do
      get '/'
      last_response.headers['Set-Cookie'].should =~ /_utmarr/
    end
  end
end
