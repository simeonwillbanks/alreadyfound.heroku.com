class Service
  attr_reader :win, :name
  def initialize opts
    @win = opts[:win] || "_blank"
    @username = opts[:username] || ""
  end
  def url 
    @url.sub("%u", @username)
  end
end

class DeliciousService < Service
  def initialize opts
    super opts
    @name = "Delicious"
    @url = "http://www.delicious.com/search?p=%q&chk=&context=userposts|%u&fr=del_icio_us&lc=1"
  end
end

class GoogleBookmarksService < Service
  def initialize opts
    super opts
    @name = "Google Bookmarks"
    @url = "https://www.google.com/bookmarks/l#q=%q"
  end
end