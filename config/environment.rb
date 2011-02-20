RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

class RackRailsCookieHeaderHack
  def initialize(app)
    @app = app
  end
  def call(env)
    status, headers, body = @app.call(env)
    if headers['Set-Cookie'] && headers['Set-Cookie'].respond_to?(:collect!)
      headers['Set-Cookie'].collect! { |h| h.strip }
    end
    [status, headers, body]
  end
end

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.after_initialize do
    ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, RackRailsCookieHeaderHack)
  end
end
