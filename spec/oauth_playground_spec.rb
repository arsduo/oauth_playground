require 'spec_helper'

describe 'OAuthPlayground' do

  
  it 'should load the index' do
    get '/'
    last_response.should.be.ok
  end
end

