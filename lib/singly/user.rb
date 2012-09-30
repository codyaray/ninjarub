require "ostruct"
require "httparty"

class Singly::User < OpenStruct
  include HTTParty
  base_uri ENV['SINGLY_URI'] || "https://api.singly.com"

  attr_accessor :access_token

  def initialize(access_token)
    @access_token = access_token
    self.class.default_params :access_token => @access_token
  end

  def profiles
    self.class.get("/profiles")
  end

  def profile(name)
    self.class.get("/profiles/#{name}")
  end

  def raw_profiles
    self.class.get("/profiles?data=true")
  end

  def facebook(name)
    profile("facebook")
  end

  def dropbox
    profile("dropbox")
  end

  def fitbit
    profile("facebook")
  end

  def flickr
    profile("flickr")
  end

  def foursquare
    profile("foursquare")
  end

  def github
    profile("github")
  end

  def google_contacts
    profile("google-contacts")
  end

  def instagram
    profile("instagram")
  end

  def linkedin
    profile("linkedin")
  end

  def meetup
    profile("meetup")
  end

  def runkeeper
    profile("runkeeper")
  end

  def stocktwits
    profile("stocktwits")
  end

  def tout
    profile("tout")
  end

  def tumblr
    profile("tumblr")
  end

  def twitter
    profile("twitter")
  end

  def withings
    profile("withings")
  end

  def wordpress
    profile("wordpress")
  end

  def yammer
    profile("yammer")
  end

  def zeo
    profile("zeo")
  end

end
