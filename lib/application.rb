require "rubygems"
require "httparty"
require "sinatra"
require "omniauth-singly"
require 'rack/session/dalli' #from dalli gem
require_relative "./singlytics"
require_relative "./singly"

SINGLY_API_BASE = "https://api.singly.com"
APPLICATION_NAME = "ninjarub"

use Rack::Session::Dalli, :memcache_server => 'localhost:11211', :compression => true
enable :logging, :dump_errors, :raise_errors

use OmniAuth::Builder do
  provider :singly, ENV['SINGLY_ID'], ENV['SINGLY_SECRET']
end

get "/" do
  if session[:access_token]
    @profiles = HTTParty.get(profiles_url, {
      :query => {:access_token => session[:access_token]}
    }).parsed_response
  end
  erb :index
end

get "/auth/singly/callback" do
  auth = request.env["omniauth.auth"]
  session[:access_token] = auth.credentials.token
  if session[:singlytics]
    logger.info "Have singlytics"
    session[:singlytics].update_from_singly(session[:access_token]).save
  else
    logger.info "No singlytics"
    session[:singlytics] = Singlytics::Profile.fetch_from_token(APPLICATION_NAME, session[:access_token]).save
  end
  redirect "/"
end

get "/logout" do
  session.clear
  redirect "/"
end

def profiles_url
  "#{SINGLY_API_BASE}/profiles"
end
