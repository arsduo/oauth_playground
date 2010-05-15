APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'sinatra'
require 'erb'

class OAuthPlayground < Sinatra::Application
  
  set :root, APP_ROOT  

  include Koala

  layout :layout

  get "/" do
    @app_data = FACEBOOK_INFO.merge("callback_url" => "#{request.scheme}://#{request.host}/")
    @oauth = Facebook::OAuth.new(@app_data["app_id"], @app_data["secret_key"], @app_data["callback_url"])
    
    # get authentication info
    set_facebook_cookies 
    set_oauth_data
    set_access_token
    
    unless (@permissions = params[:permissions]) && @permissions.length > 0
      @active_permissions = (get_active_permissions || {}).inject([]) do |active, perm| 
        # collect our active permissions
        active << perm[0].to_sym if perm[1] == 1
        active
      end
      @fetched_permissions = true
    else
      @active_permissions = @permissions.collect {|p| p.to_sym}
    end
        
    @available_permissions = [
      {:name => "User Activity", :perms => ACTIVITY_PERMISSIONS},
      {:name => "User Info", :perms => USER_PERMISSIONS},
      {:name => "Friend Info", :perms => FRIEND_PERMISSIONS}
    ]
  
    erb :index
  end
  
  helpers do
    def logger
      LOGGER
    end 
  end

  # helpers

  # set up our understanding of the user's session
  
  def set_access_token
    # get the access token from wherever we can
    @access_token ||= (set_oauth_data && @oauth_access_token) || (set_facebook_cookies && @cookie_access_token)
  end
  
  def set_oauth_data
    unless @oauth_access_token
      if (@code = params[:code]) && @raw_access_response = @oauth.fetch_token_string(@code)
        parsed = @oauth.parse_access_token(@raw_access_response)
        @oauth_access_token = parsed["access_token"]
        @expiration = parsed["expires"] || "Does not expire (offline)"
      end
    end
    
    @oauth_access_token
  end
  
  def set_facebook_cookies
    unless @facebook_cookies
      if @facebook_cookies = @oauth.get_user_from_cookie(request.cookies)
        @cookie_access_token = @facebook_cookies["access_token"]
      end
    end
    
    @facebook_cookies
  end
  
  def set_uid
    # get the OAuth data, including fetching the access token, if available and necessary
    # e.g. if we have an OAuth token and no cookie data    
    unless @uid 
      if @facebook_cookies
        @uid = @facebook_cookies["uid"]
      elsif token = access_token
        # we have to fetch the info
        @graph = Facebook::GraphAPI.new(token)
        result = @graph.get_object("me")
        @uid = result["uid"]
      end
    end
    @uid
  end
  
  # fetch the active permissions about the user    
  def get_active_permissions
    set_access_token
    if @access_token && !@permissions && set_uid
      # if we don't have permissions set but have an access token
      # grab the user's info
      @rest = Facebook::RestAPI.new(@access_token)      
      result = @rest.fql_query("select #{all_permissions.join(",")} from permissions where uid = #{@uid.to_s}")
      result.first
    end  
  end
  
  # list of permissions

  def all_permissions
    ACTIVITY_PERMISSIONS + USER_PERMISSIONS + FRIEND_PERMISSIONS
  end
  
  ACTIVITY_PERMISSIONS = [
    :publish_stream, # Enables your application to post content, comments, and likes to a user's stream and to the streams of the user's friends, without prompting the user each time.
    :create_event, # Enables your application to create and modify events on the user's behalf
    :rsvp_event, # Enables your application to RSVP to events on the user's behalf
    :sms, # Enables your application to send messages to the user and respond to messages from the user via text message
    :offline_access # Enables your application to perform authorized requests on behalf of the user at any time. By default, most access tokens expire after a short time period to ensure applications only make requests on behalf of the user when the are actively using the application. This permission makes the access token returned by our OAuth endpoint long-lived.
  ]

  USER_PERMISSIONS = [
    :email, # Provides access to the user's primary email address in the email property. Do not spam users. Your use of email must comply both with Facebook policies and with the CAN-SPAM Act.
    :read_insights, # Provides read access to the Insights data for pages, applications, and domains the user owns.
    :read_stream, # Provides access to all the posts in the user's News Feed and enables your application to perform searches against the user's News Feed
    :user_about_me, # Provides access to the "About Me" section of the profile in the about property
    :user_activities, # Provides access to the user's list of activities as the activities connection
    :user_birthday, # Provides access to the full birthday with year as the birthday_date property
    :user_education_history, # Provides access to education history as the education property
    :user_events, # Provides access to the list of events the user is attending as the events connection
    :user_groups, # Provides access to the list of groups the user is a member of as the groups connection
    :user_hometown, # Provides access to the user's hometown in the hometown property
    :user_interests, # Provides access to the user's list of interests as the interests connection
    :user_likes, # Provides access to the list of all of the pages the user has liked as the likes connection
    :user_location, # Provides access to the user's current location as the current_location property
    :user_notes, # Provides access to the user's notes as the notes connection
    :user_online_presence, # Provides access to the user's online/offline presence
    :user_photo_video_tags, # Provides access to the photos the user has been tagged in as the photos connection
    :user_photos, # Provides access to the photos the user has uploaded
    :user_relationships, # Provides access to the user's family and personal relationships and relationship status
    :user_religion_politics, # Provides access to the user's religious and political affiliations
    :user_status, # Provides access to the user's most recent status message
    :user_videos, # Provides access to the videos the user has uploaded
    :user_website, # Provides access to the user's web site URL
    :user_work_history # Provides access to work history as the work property
  ]
  
  FRIEND_PERMISSIONS = [
    :read_friendlists, # Provides read access to the user's friend lists
    :read_requests, # Provides read access to the user's friend requests
    :friends_about_me, # Provides access to the "About Me" section of the profile in the about property
    :friends_activities, # Provides access to the user's list of activities as the activities connection
    :friends_birthday, # Provides access to the full birthday with year as the birthday_date property
    :friends_education_history, # Provides access to education history as the education property
    :friends_events, # Provides access to the list of events the user is attending as the events connection
    :friends_groups, # Provides access to the list of groups the user is a member of as the groups connection
    :friends_hometown, # Provides access to the user's hometown in the hometown property
    :friends_interests, # Provides access to the user's list of interests as the interests connection
    :friends_likes, # Provides access to the list of all of the pages the user has liked as the likes connection
    :friends_location, # Provides access to the user's current location as the current_location property
    :friends_notes, # Provides access to the user's notes as the notes connection
    :friends_online_presence, # Provides access to the user's online/offline presence
    :friends_photo_video_tags, # Provides access to the photos the user has been tagged in as the photos connection
    :friends_photos, # Provides access to the photos the user has uploaded
    :friends_relationships, # Provides access to the user's family and personal relationships and relationship status
    :friends_religion_politics, # Provides access to the user's religious and political affiliations
    :friends_status, # Provides access to the user's most recent status message
    :friends_videos, # Provides access to the videos the user has uploaded
    :friends_website, # Provides access to the user's web site URL
    :friends_work_history # Provides access to work history as the work property
  ]
end
