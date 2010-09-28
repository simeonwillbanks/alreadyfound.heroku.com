require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

post '/bookmarklet' do
  name = params[:name]
  mail = params[:mail]
  body = params[:body]
          
  haml :bookmarklet
end