var query,
    selection,
    google_url='http://www.google.com/search?q=%q';
    google_win='';
    service_url='';
    service_win='';
    service_name='';
if(window.getSelection){
  selection=window.getSelection();
  if(selection.toString().length>0)
    query=selection;
}
if(!query)
  void(query=prompt('Enter search term for Google and '+service_name,''));
if(query){
  query=escape(query);
  window.open(google_url.replace('%q',query),google_win);
  window.open(service_url.replace('%q',query),service_win);
}