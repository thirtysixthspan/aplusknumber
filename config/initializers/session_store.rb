# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_aplusknumber_session',
  :secret      => 'a2f629a84f73d973bbdd7ac7d5ef456bbd40c1b32e6ae3fddd39f4673b17a8be7abea1ae6f58eac162a57ff35af466c0bcac1c3e396108aae6087296f2e36981'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
