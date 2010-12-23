require "sinatra"
require "haml"
require "rack-flash"

set :app_file, __FILE__
set :root, File.dirname(__FILE__)

configure :development do
  require "sinatra/reloader"
end

configure :production do
  not_found do
    haml :'404'
  end

  error do
    haml :'500'
  end
end

["bookmarklet", "googlesearch", "service"].each do |lib|   
  require Sinatra::Application.root + "/lib/" + lib
end

enable :sessions
use Rack::Flash

helpers do
  def href(googlewin, opts)
    google_search = GoogleSearch.new googlewin
    service = Object.const_get("#{opts.delete(:service)}Service").new opts
    bm = Bookmarklet.new google_search, service
    bm.source()
  end
end

before do
  @blank = "_blank"
  @parent = "_parent"
  
  # Delicious bookmarklet form validation 
  if request.path_info == "/delicious/bookmarklet" 
    if params[:username].empty?
      flash[:error] = "Username is required"
      redirect '/delicious'    
    end
  end
end

get "/" do
  haml :index
end

get "/delicious" do
  @username = session["username"] 
  haml :delicious
end

get "/google" do
  haml :google
end

post "/delicious/bookmarklet" do  
  if params[:newwin] == "delicious"
    deliciouswin = @blank
    googlewin = @parent
  else
    deliciouswin = @parent 
    googlewin = @blank
  end
  
  session["username"] = params[:username]
  
  @href = href(googlewin, {:username => params[:username], 
                           :win => deliciouswin,
                           :service => "Delicious"})
  haml :bookmarklet
end

post "/google/bookmarklet" do
  if params[:newwin] == "bookmarks"
    bookmarkswin = @blank
    googlewin = @parent
  else
    bookmarkswin = @parent 
    googlewin = @blank
  end
  
  @href = href(googlewin, {:win => bookmarkswin,
                           :service => "GoogleBookmarks"})
  haml :bookmarklet
end