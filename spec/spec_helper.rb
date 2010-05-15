require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'typhoeus'
require 'koala'

require File.join(File.dirname(__FILE__), '..', 'lib', 'oauth_playground.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'load_facebook.rb')

OAuthPlayground.set(
  :environment => :test,
  :run => false,
  :raise_errors => true,
  :logging => false
)

module TestHelper
  
  def app
    # change to your app class if using the 'classy' style
    OAuthPlayground
  end
  
  def body
    last_response.body
  end
  
  def status
    last_response.status
  end
  
  include Rack::Test::Methods

end

include TestHelper