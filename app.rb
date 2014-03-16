require 'sinatra'
require 'data_mapper'
require 'oauth2'
require 'json'

SESSION_SECRET= ENV['SESSION_SECRET']
G_API_CLIENT= ENV['G_API_CLIENT']
G_API_SECRET= ENV['G_API_SECRET']
G_API_SCOPES = [
			'https://www.googleapis.com/auth/plus.me',
			'https://www.googleapis.com/auth/userinfo.email',
			'https://www.googleapis.com/auth/userinfo.profile'].join(' ')

class GUser
	include DataMapper::Resource
	property :id, Serial, :key => true
	property :email, String, length:120
	property :handle, String, length:30
	property :name, String, length:40
	property :family_name, String, length:20
	property :image, Text
	property :secret, Text
	property :api_key, String, length:200
end

class GSampleServer < Sinatra::Base
	enable :sessions

	set :views_folder,  "#{settings.root}/../lib/views"
	set :public_folder, "#{settings.root}/../public"
	set :session_secret, SESSION_SECRET 

	def client
		client ||= OAuth2::Client.new(G_API_CLIENT, G_API_SECRET, {
			:site => 'https://accounts.google.com',
			:authorize_url => "/o/oauth2/auth",
			:token_url => "/o/oauth2/token"
		})
	end

	before do
		pass if request.path_info == '/auth/g_callback'
		pass if request.path_info == '/signout'

		if session[:access_token]

			access_token = OAuth2::AccessToken.from_hash(client, { 
				:access_token => session[:access_token], 
				:refresh_token =>  session[:refresh_token], 
				:header_format => 'OAuth %s' } ).refresh!
			access_token.refresh!

			session[:access_token]  = access_token.token
			session[:refresh_token] = access_token.refresh_token

			info = access_token.get("https://www.googleapis.com/oauth2/v3/userinfo").parsed
			@user = GUser.first(:email=>info["email"]) || GUser.create(:email=>info["email"])
			@user.name = info["name"]
			@user.family_name = info["family_name"]
			@user.image = info["picture"]
			@user.save
		end
	end

	get '/' do
		if !session[:access_token].nil?
			erb :index, layout:@layout
		else
			@g_sign_in_url = client.auth_code.authorize_url(:redirect_uri => g_redirect_uri,:scope => G_API_SCOPES,:access_type => "offline")
			erb :sign_in, layout:@layout
		end
	end

	get '/signout' do
		session[:access_token] = nil
		session[:refresh_token] = nil
		redirect '/'
	end

	get '/auth/g_callback' do
		new_token = client.auth_code.get_token(params[:code], :redirect_uri => g_redirect_uri)
		session[:access_token]  = new_token.token
		session[:refresh_token] = new_token.refresh_token
		redirect '/'
	end

	def g_redirect_uri
		uri = URI.parse(request.url)
		uri.path = '/auth/g_callback'
		uri.query = nil
		uri.to_s
	end

	def access_token
		OAuth2::AccessToken.new(client, session[:access_token], :refresh_token => session[:refresh_token])
	end

end
