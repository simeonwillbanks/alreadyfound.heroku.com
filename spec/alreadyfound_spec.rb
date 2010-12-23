require File.dirname(__FILE__) + '/spec_helper'

describe DeliciousService do
  it "should correctly set instance variable public values" do
    win = "_parent"
    service = DeliciousService.new :win => win, :username => "tester"
    service.name.should == "Delicious"
    service.url.should == "http://www.delicious.com/search?p=%q&chk=&context=userposts|tester&fr=del_icio_us&lc=1"
    service.win.should == win
  end  
end

describe GoogleBookmarksService do
  it "should correctly set instance variable public values" do
    win = "_blank"
    service = GoogleBookmarksService.new :win => win
    service.name.should == "Google Bookmarks"
    service.url.should == "https://www.google.com/bookmarks/l#q=%q"
    service.win.should == win
  end  
end

describe Bookmarklet do
  
  before(:each) do
    @template = "var query,selection,google_url='http://www.google.com/search?q=%q';google_win='';service_url='';service_win='';service_name='';if(window.getSelection){selection=window.getSelection();if(selection.toString().length>0)query=selection;}if(!query)void(query=prompt('Enter search term for Google and '+service_name,''));if(query){query=escape(query);window.open(google_url.replace('%q',query),google_win);window.open(service_url.replace('%q',query),service_win);}" 
    @google_search = GoogleSearch.new "_parent"
    @service = GoogleBookmarksService.new :win => "_blank"
    @bookmarklet = Bookmarklet.new @google_search, @service
    # Send a message to Bookmarklet saying set all protected methods to public
    Bookmarklet.send(:public, *Bookmarklet.protected_instance_methods)
  end 
  
  it "should open javascript template file" do
    @bookmarklet.javascript.should == @template
  end
  
  it "should substitute javascript source with instance variables" do
    subbed = @bookmarklet.sub(@template)
    subbed.should be_an_instance_of(String)
    subbed.should include "google_win='" + @google_search.win
    subbed.should include "service_win='" + @service.win
    subbed.should include "service_url='" + @service.url
    subbed.should include "service_name='" + @service.name
  end
  
  it "should encode the bookmarklet source" do
    url = "http://rspec.info/documentation/before_and_after.html"
    encoded = @bookmarklet.encode(url)
    encoded.should == "http%3A%2F%2Frspec.info%2Fdocumentation%2Fbefore_and_after.html"
  end
  
  it "should prepend bookmarklet with javascript pseudo-scheme" do
    prepended = @bookmarklet.prepend(@template)
    prepended.should == "javascript:" + @template
  end
   
end

describe "Already Found" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  it "should return the correct content-type when viewing root" do
    get '/'
    last_response.headers["Content-Type"].should == "text/html"
  end
  
  it "should render specific text when viewing root" do
    get '/'
    last_response.body.should include 'Already Found'
    last_response.body.should include 'Already Found Is A Search Bookmarklet'
    last_response.body.should include 'Which service do you use to save bookmarks?'
    last_response.body.should include 'Google'
    last_response.body.should include 'Delicious'
  end

  it "should render specific text when viewing form to create delicious bookmarklet" do
    get '/delicious'
    last_response.body.should include 'Already Found'
    last_response.body.should include 'Simultaneously search Delicious Bookmarks'
    last_response.body.should include 'Set your bookmarklet preferences and create your bookmarklet'
    last_response.body.should include 'Which search result should open in a new window?'
    last_response.body.should include 'Delicious username'
    last_response.body.should include 'Google'
    last_response.body.should include 'Delicious'
  end

  it "should render specific text when viewing form to create google bookmarklet" do
    get '/google'
    last_response.body.should include 'Already Found'
    last_response.body.should include 'Simultaneously search Google Bookmarks'
    last_response.body.should include 'Set your bookmarklet preferences and create your bookmarklet'
    last_response.body.should include 'Which search result should open in a new window?'
  end

  it "should redirect and display error when delicious bookmarklet form submitted without delicious username" do
    post "/delicious/bookmarklet", {:username => "", :newwin => "google"}
    last_response.status.should == 302
    last_response.headers["Location"].should == "/delicious"
    # Get flash error and do redirect
    error = last_response.headers['Set-Cookie']
    get '/delicious', '', { "HTTP_COOKIE" => error }
    last_response.should be_ok
    last_response.body.should include "Username is required"
  end
  
  it "should render a Delicious bookmarklet on successful Delicious bookmarklet form submission" do
    username = "rspec"
    deliciouswin = "_parent"
    googlewin = "_blank"
    post "/delicious/bookmarklet", {:username => username, :newwin => "google"}
    last_response.should be_ok
    google_search = GoogleSearch.new googlewin
    service = DeliciousService.new :win => deliciouswin, :username => username
    bm = Bookmarklet.new google_search, service
    last_response.body.should include bm.source()
  end
  
  it "should render a Google Bookmarks bookmarklet on successful Google Bookmarks bookmarklet form submission" do
    post "/google/bookmarklet", {:newwin => "bookmarks"}
    last_response.should be_ok
    google_search = GoogleSearch.new "_parent"
    service = GoogleBookmarksService.new :win => "_blank"
    bookmarklet = Bookmarklet.new google_search, service
    last_response.body.should include bookmarklet.source()
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
  
end