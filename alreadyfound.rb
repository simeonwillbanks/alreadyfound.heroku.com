require "sinatra"
require "haml"
require "rack-flash"

# Specs run from ./spec dir so lib path different than dev or prod
configure :test do
  @libpath = "../lib/"
end
  
configure :development do
  @libpath = "lib/"
  require "sinatra/reloader"
end

configure :production do
  @libpath = "lib/"
  
  not_found do
    haml :'404'
  end

  error do
    haml :'500'
  end
end

# Libraries
require @libpath + "bookmarklet"

enable :sessions
use Rack::Flash

helpers do
  def href(username, deliciouswin, googlewin)
    bm = Bookmarklet.new username, deliciouswin, googlewin
    bm.src
  end
end

before do
  # Bookmarklet form validation 
  if request.path_info == "/bookmarklet" 
    if params[:username].empty?
      flash[:error] = "Username is required"
      redirect '/'    
    end
  end
end

get "/" do
  @username = session["username"] 
  haml :index
end

post "/bookmarklet" do
  blank = "_blank"
  parent = "_parent"
  
  if params[:newwin] == "delicious"
    deliciouswin = blank
    googlewin = parent
  else
    deliciouswin = parent 
    googlewin = blank
  end
  
  session["username"] = params[:username]
  
  @href = href(params[:username], deliciouswin, googlewin)
  haml :bookmarklet
end