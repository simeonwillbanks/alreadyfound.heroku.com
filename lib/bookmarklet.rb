class Bookmarklet
  TEMPLATE = File.join(File.dirname(__FILE__), '..', "public/js/bookmarklet/template.js")

  def initialize(google_search, service)
    @google_search = google_search
    @service = service
  end
      
  def source
    js = sub(javascript)
    js = encode(js)
    js = prepend(js)
    js
  end

  protected

    def javascript
      str = ""
      file = File.open(TEMPLATE, "r")
      file.each do |line| 
        unless line.empty?
          line.strip!
          str << line
        end
      end
      file.close
      str  
    end

    def sub(str)
      str.sub("google_win=''", "google_win='" + @google_search.win + "'").
          sub("service_url=''", "service_url='" + @service.url + "'").
          sub("service_win=''", "service_win='" + @service.win + "'").
          sub("service_name=''", "service_name='" + @service.name + "'")
    end

    def encode(str)
      # Properly encode spaces and search URIs 
      URI.encode(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))    
    end

    def prepend(str)
      # Prepend JavaScript pseudo-scheme
      "javascript:" + str
    end
end