require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'

class Task
  include MongoMapper::Document

  before_validation :set_expires

  scope :by_expires, lambda { |date| where(:expires.lt => date)}

  key :description, String
  key :user_id, String
  key :expires, Time
  key :time_type, Integer
  key :completed, Boolean
  key :provider, String
  key :uid, Integer

  def set_expires
    now = Time.new
    if(time_type == 0)
      self.expires = now.end_of_day()
    elsif(time_type == 1)
      self.expires = now.end_of_month()
    elsif(time_type == 2)
      self.expires = now.end_of_year()
    end

  end
end

class User
  include MongoMapper::Document

  key :provider, String
  key :uid, Integer
  key :username, String
end

configure :test do
  set :twitterKey => 'Uwk8eu2sGU8HGhzvCK8aA'
  set :twitterSecret => '78vXIZQ31n5lWELfPNnnqWZGwgZjzvoZorqzPPRmSSA'
  set :facebookId => '369643956424034'
  set :facebookSecret => 'd9027d2a57eb62b1bedf56d2245eca71'

  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
  use Rack::Session::Cookie, :key => 'rack.session',
      :domain => 'threetasks.heroku.com',
      :path => '/',
      :expire_after => 2592000, # In seconds
      :secret => 'zP501rH3Q7HvsWVrN1la'
end

configure :development do
  set :twitterKey => 'our1xG0LeJcCXLj0MAMLg'
  set :twitterSecret => 'quMYVPmoZoW8FGlfkaAkRfHwq68YC7UtD02OMDLYg'
  set :facebookId => '245420668897155'
  set :facebookSecret => 'b5465dc90761c27db32b00d523133d87'

  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
  use Rack::Session::Cookie, :key => 'rack.session',
      :domain => 'localhost',
      :path => '/',
      :expire_after => 2592000, # In seconds
      :secret => '4mS9hhH7LLb7858Hbrye'
end

use OmniAuth::Builder do
  provider :twitter, settings.twitterKey, settings.twitterSecret
  provider :facebook, settings.facebookId, settings.facebookSecret
end

get '/' do
  user_id = session[:user_id] || request.cookies['userid']
  puts user_id
  if(user_id.nil?)
    erb :preauth
  else
    erb :index
  end
end

get '/about' do
  erb :about
end

get '/contact' do
  erb :contact
end

post '/signout' do
  session.clear
end

get '/tasks' do
  content_type :json
  Task.delete_all(:expires => {:$lt => Time.now})

  @task = Task.where(:provider => session[:provider], :uid => session[:uid].to_i).limit(3).all

  while @task.length < 3
    emptyTask = Task.new(:description => "Enter Task", :time_type => 0, :user_id => session[:user_id],
    :provider => session['provider'], :uid => session['uid'].to_i)

    emptyTask.save()
    @task.push(emptyTask)
  end

  @task.to_json
end

put '/tasks/:id' do
  content_type :json
  task = Task.find_by_id(params[:id])
  task.update_attributes!(JSON.parse request.body.read)
  task.provider = session[:provider]
  task.uid = session[:uid].to_i
  task.user_id = session[:user_id]
  task.to_json
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  user = User.where(:provider => auth["provider"], :uid => auth["uid"].to_i).first() ||
      User.create(:provider => auth["provider"], :uid => auth["uid"].to_i, :name => auth['info']['name'])

  session[:user_id] = user.id
  session[:user_name] = user.name
  session[:uid] = auth['uid'].to_i
  session[:provider] = auth['provider']

  response.set_cookie('user_name', user.name)
  response.set_cookie('userid', user.id)
  response.set_cookie('provider', auth['provider'])
  response.set_cookie('uid', auth['uid'].to_i)
  redirect '/'
end