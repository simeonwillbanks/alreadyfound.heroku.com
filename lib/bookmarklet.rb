class Bookmarklet
  TEMPLATE = File.join(File.dirname(__FILE__), '..', "public/js/bookmarklet/template.js")
  attr_reader :src
  
  def initialize(username, deliciouswin, googlewin)
    @username = username
    @deliciouswin = deliciouswin
    @googlewin = googlewin
  end
  
  def parse()
    @src = source()
    sub!(@src)
    @src = encode(@src)
    @src = prepend(@src)
  end

  protected

    def source()
      source = ""
      file = File.open(TEMPLATE, "r")
      file.each do |line| 
        unless line.empty?
          line.strip!
          source << line
        end
      end
      file.close
      source  
    end

    def sub!(str)
      str.sub!("username", @username)
      str.sub!("dwin='_blank'", "dwin='" + @deliciouswin + "'")
      str.sub!("gwin='_parent'", "gwin='" + @googlewin + "'")    
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