require "sinatra"
require "haml"
require "rack-flash"
require "lib/bookmarklet"

configure :development do |config|
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