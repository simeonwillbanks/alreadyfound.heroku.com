require File.dirname(__FILE__) + '/spec_helper'

describe "Already Found" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  # Rack::Test methods
  
  def test_home_text
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Already Found')
    assert last_response.body.include?('Create Your Bookmarklet')
    assert last_response.body.include?('Set your bookmarklet preferences.')
    assert last_response.body.include?('Which search result should open in a new window?:')
    assert last_response.body.include?('Delicious username:')
    assert last_response.body.include?('Google')
    assert last_response.body.include?('Delicious')
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  # RSpec methods
  
  it "should return the correct content-type when viewing root" do
    get '/'
    last_response.headers["Content-Type"].should == "text/html"
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
end