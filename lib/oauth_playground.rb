APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'sinatra'
require 'erb'

class OAuthPlayground < Sinatra::Application
  
  set :root, APP_ROOT  

  include Koala

  layout :layout

  helpers do
    def logger
      LOGGER
    end
  end

  get "/" do
    @app_data = FACEBOOK_INFO.merge("callback_url" => "#{request.scheme}://#{request.host}/")
    @oauth = Facebook::OAuth.new(@app_data["app_id"], @app_data["secret_key"], @app_data["callback_url"])
    @facebook_cookies = @oauth.get_user_from_cookie(request.cookies)

    if (@code = params[:code]) && @raw_access_response = @oauth.fetch_token_string(@code)
      parsed = @oauth.parse_access_token(@raw_access_response)
      @oauth_access_token = parsed["access_token"]
      @expiration = parsed["expires"] || "Does not expire (offline)"
    elsif @facebook_cookies
      @cookie_access_token = @facebook_cookies["access_token"]
    end

    @access_token = @oauth_access_token || @cookie_access_token
    @permissions = params[:permissions]
  
    erb :index
  end
  
end
