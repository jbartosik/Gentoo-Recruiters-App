RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'hobo'

  config.time_zone = 'UTC'
  config.action_mailer.default_url_options = { :host => 'localhost', :port => '3000' }
end
