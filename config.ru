# gems
require 'sinatra'
require 'logger'
require 'yaml'

# app files
require 'koala'
require File.join(File.dirname(__FILE__), 'lib', 'oauth_playground.rb')

# get the environment
env = ENV["RACK_ENV"]

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

# load Facebook info for this environment
FACEBOOK_INFO = YAML.load_file(File.join(File.dirname(__FILE__), "config", "facebook.yml"))[env]

# activate the app
disable :run
set :environment, env
run OAuthPlayground