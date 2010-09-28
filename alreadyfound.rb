require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

post '/bookmarklet' do
  if params[:new_window] == "google"
    google_window = "_blank"
    delicious_window = "_parent"
  else
    google_window = "_parent"
    delicious_window = "_blank"
  end
  
  @href = "javascript:var%20q,d=[],g=[],s;d[%27username%27]=%27"+params[:username]+"%27;d[%27url%27]=%27http://delicious.com/search?p=%q&chk=&context=userposts%7C%u&fr=del_icio_us&lc=1%27;g[%27url%27]=%27http://www.google.com/search?q=%q%27;if(window.getSelection){s=window.getSelection();if(s.toString().length>0)q=s;}if(!q)void(q=prompt(%27Enter%20search%20term%20for%20Google%20and%20Delicious%27,%27%27));if(q){q=escape(q);window.open(d[%27url%27].replace(%27%q%27,q).replace(%27%u%27,d[%27username%27]),%27"+google_window+"%27);window.open(g[%27url%27].replace(%27%q%27,q),%27"+delicious_window+"%27);}"
  haml :bookmarklet
end