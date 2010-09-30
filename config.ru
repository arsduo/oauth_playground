# gems
require 'sinatra'
require 'logger'
require 'yaml'

# LOGGING
# set up the logfile
Dir.mkdir('log') unless File.exists?('log')
log_filename = File.join(File.dirname(__FILE__), "log", "sinatra.log")
log = File.new(log_filename, "a+")

# log requests
use Rack::CommonLogger, log 
# log application-generated code
LOGGER = Logger.new(log_filename) 
# log output to stdout and stderr as well
$stdout.reopen(log)
$stderr.reopen(log)

# Dreamhost doesn't play well with custom gems anymore
if ENV["RAILS_ENV"] == "production" || ENV["RACK_ENV"] == "production"
  Gem.clear_paths
  ENV["GEM_HOME"] = "/home/alexkm/.gems"
end

# app files
require 'koala'
require File.join(File.dirname(__FILE__), 'lib', 'load_facebook.rb')
require File.join(File.dirname(__FILE__), 'lib', 'oauth_playground.rb')

# activate the app
disable :run
run OAuthPlayground


