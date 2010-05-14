# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Gentoo-Recruiters-App_session',
  :secret      => '3dbea4d040e61573376e46c1770d3db4c1917cba5328c76e94dca0c5dff39610e85880cab5019dd9fde10c2c761759fed205410ae4367968b8141ffc8b133bcc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
