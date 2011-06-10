# DONT USE THIS, ITS FUCKED
# module AARRR
#   class Middleware
#
#     def initialize(app)
#       @app = app
#     end
#
#     def call(env)
#       aarrr_session = AARRR(env)
#
#       status, headers, body = @app.call(env)
#       # require 'ruby-debug';debugger
#       # sets a tracking cookie on the response
#       response = Rack::Response.new body, status, headers
#       # aarrr_session.set_cookie(response)
#
#       response.finish
#     end
#
#   end
# end