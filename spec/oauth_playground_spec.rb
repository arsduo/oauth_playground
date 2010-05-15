require 'spec_helper'
require 'ruby-debug'

describe 'OAuthPlayground' do
  before :each do
    @hydra = Typhoeus::Hydra.hydra
  end
  
  after :each do 
    @hydra.clear_stubs
  end
  
  it 'should load the index' do
    get '/'
    last_response.should be_ok
  end

=begin  
  # unfortunately, this fails when you pass the get method a param named code!
  # fixing this will require some mucking around in Rack::Test
  
  it "should make a request to Facebook's OAuth server when passed a code" do 
    test_string = Regexp.new("The time is #{Time.now.to_i}")

    # stub out the request and make sure it's returned
    @hydra.stub("https://#{Koala::Facebook::GRAPH_SERVER}/oauth/access_token", "get").and_return(test_string)
    
    get "/", {"code" => "foo_bar"}

    # make sure the body includes the request string
    last_response.body.should =~ test_string
  end
=end
end

