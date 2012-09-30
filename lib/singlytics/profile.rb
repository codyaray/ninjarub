require "ostruct"
require "httparty"

#
#  require 'singlytics'
#  
#  @profile = Singlytics::Profile.new('ninja-mob', '1934o23u4123u41324')
#  @profile.location = 'Chicago'
#  @profile.update(:location => 'Chicago', :timezone => '-5:00')
#  @profile.save
#  
#  @profile.update(:location => 'Chicago', :timezone => '-5:00').save
#
class Singlytics::Profile < OpenStruct
  include HTTParty
  base_uri ENV['HYPERION_URI']

  SINGLY_API_BASE = "https://api.singly.com"
  DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }

  attr_reader :application, :account

  def self.fetch_from_token(application, access_token)
    puts "loaded: #{access_token}"
    profile = Singlytics::Profile.new(application, account(access_token))
    profile.update_from_singly(access_token)
    profile
  end

  def initialize(application, account)
    @application, @account = application, account
  end

  def fetch
    response = self.class.get("/profile/#{@application}/#{@account}/")
    puts "response.body: #{response.body}"
    marshal_load(JSON.parse(response.body)) unless response.body == ""
    self
  end

  def update(body, options = {})
    # overwrite marshalled body with updated body
    marshal_load (marshal_dump || {}).merge(body)
    self
  end

  def update_from_singly(access_token)
    update(filter(::Singly::User.new(access_token).raw_profiles))
    self
  end

  def save
    puts "saving #{marshal_dump}"
    options = { :body => marshal_dump, :headers => DEFAULT_HEADERS }
    self.class.put("/profile/#{@application}/#{@account}/", options)
    self
  end

private

  FILTER_KEYS = [
    "id", "bio", "birthday", "dateOfBirth", "description", "lang", "gender",
    "timezone", "languages", "locale", "location", "utc_offset"
  ]

  def filter(json)
    data = {}
    data["id"] = json["id"]
    %w[facebook github flickr linkedin twitter].each do |service|
      (json[service]||[]).each do |arr|
        arr.each do |key, val|
          next unless FILTER_KEYS.include?(key)
          data[key] = val
        end
      end
    end
    data
  end

  def self.account(access_token)
    puts access_token
    HTTParty.get("#{SINGLY_API_BASE}/profiles", {
      :query => {:access_token => access_token}
    }).parsed_response["id"]
  end

end
