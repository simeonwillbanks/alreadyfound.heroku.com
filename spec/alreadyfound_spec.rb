require File.dirname(__FILE__) + '/spec_helper'

describe "Bookmarklet" do
  
  before(:each) do
    @source = "var q,d,g,s;duser='username';dwin='_blank';gwin='_parent';durl='http://delicious.com/search?p=%q&chk=&context=userposts%7C%u&fr=del_icio_us&lc=1';gurl='http://www.google.com/search?q=%q';if(window.getSelection){s=window.getSelection();if(s.toString().length>0)q=s;}if(!q)void(q=prompt('Enter search term for Google and Delicious',''));if(q){q=escape(q);window.open(durl.replace('%q',q).replace('%u',duser),dwin);window.open(gurl.replace('%q',q),gwin);}"
    @username = "rspec"
    @deliciouswin = "_parent"
    @googlewin = "_blank"
    @bookmarklet = Bookmarklet.new @username, @deliciouswin, @googlewin
  end 
  
  it "should open javascript source file" do
    class Bookmarklet 
      def get_source 
        source()
      end
    end
    @bookmarklet.get_source().should == @source
  end
  
  it "should substitute javascript source with instance variables" do
    class Bookmarklet 
      def do_sub!(str)
        sub!(str)
      end
    end
    subbed = @bookmarklet.do_sub!(@source)
    subbed.should be_an_instance_of(String)
    subbed.should include("duser='" + @username)
    subbed.should include("dwin='" + @deliciouswin)
    subbed.should include("gwin='" + @googlewin)
  end
  
  it "should encode the bookmarklet source" do
    class Bookmarklet 
      def do_encode(str)
        encode(str)
      end
    end
    url = "http://rspec.info/documentation/before_and_after.html"
    encoded = @bookmarklet.do_encode(url)
    encoded.should == "http%3A%2F%2Frspec.info%2Fdocumentation%2Fbefore_and_after.html"
  end
  
  it "should prepend bookmarklet with javascript pseudo-scheme" do
    class Bookmarklet 
      def do_prepend(str)
        prepend(str)
      end
    end
    prepended = @bookmarklet.do_prepend(@source)
    prepended.should == "javascript:" + @source
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
    last_response.body.should include('Already Found')
    last_response.body.should include('Create Your Bookmarklet')
    last_response.body.should include('Set your bookmarklet preferences.')
    last_response.body.should include('Which search result should open in a new window?:')
    last_response.body.should include('Delicious username:')
    last_response.body.should include('Google')
    last_response.body.should include('Delicious')
  end

  it "should redirect and display error when bookmarklet form submitted without delicious username" do
    post "/bookmarklet", {:username => "", :newwin => "google"}
    last_response.status.should == 302
    last_response.headers["Location"].should == "/"
    # Get flash error and do redirect
    error = last_response.headers['Set-Cookie']
    get '/', '', { "HTTP_COOKIE" => error }
    last_response.should be_ok
    last_response.body.should include("Username is required")
  end
  
  it "should render a bookmarklet on successful bookmarklet form submission" do
    username = "rspec"
    deliciouswin = "_parent"
    googlewin = "_blank"
    post "/bookmarklet", {:username => username, :newwin => "google"}
    last_response.should be_ok
    bm = Bookmarklet.new username, deliciouswin, googlewin
    bm.parse()
    last_response.body.should include(bm.src)
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
  
end