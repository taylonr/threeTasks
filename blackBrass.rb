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
  key :user_id, ObjectId
  key :expires, Time
  key :time_type, Integer
  key :completed, Boolean

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
  enable :sessions
end

configure :development do
  set :twitterKey => 'our1xG0LeJcCXLj0MAMLg'
  set :twitterSecret => 'quMYVPmoZoW8FGlfkaAkRfHwq68YC7UtD02OMDLYg'
  set :facebookId => '245420668897155'
  set :facebookSecret => 'b5465dc90761c27db32b00d523133d87'

  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
  enable :sessions
end

use OmniAuth::Builder do
  provider :twitter, settings.twitterKey, settings.twitterSecret
  provider :facebook, settings.facebookId, settings.facebookSecret
end

get '/' do
  user_id = session[:user_id]
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
   puts session[:user_id]
  @task = Task.where(:user_id => session[:user_id]).limit(3).all
  while @task.length < 3
    emptyTask = Task.new(:description => "Enter Task", :time_type => 0)
    emptyTask.save()
    @task.push(emptyTask)
  end
  @task.to_json
end

put '/tasks/:id' do
  content_type :json
  task = Task.find_by_id(params[:id])
  task.update_attributes!(JSON.parse request.body.read)
  puts session[:user_id]
  task.user_id = session[:user_id]
  task.save()
  puts 'saved'
  puts session[:user_id]
  task.to_json
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  user = User.where(:provider => auth["provider"], :uid => auth["uid"].to_i).first() ||
      User.create(:provider => auth["provider"], :uid => auth["uid"], :name => auth['info']['name'])
  session[:user_id] = user.id
  session[:user_name] = user.name
  redirect '/'
end