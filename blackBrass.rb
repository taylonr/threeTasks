require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'

class Task
  include MongoMapper::EmbeddedDocument

  before_validation :set_expires
  embedded_in :user

  key :description, String
  key :expires, Time
  key :time_type, Integer
  key :completed, Boolean

  def reset
    self.description = 'Enter Task'
    self.completed = false
  end

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

  many :tasks
end

configure do
  $stdout.sync = true
  mongo_uri = ENV['connectionString']
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = ENV['databaseName']
  use Rack::Session::Cookie, :key => 'rack.session',
      :domain => ENV['domainName'],
      :path => '/',
      :expire_after => 2592000, # In seconds
      :secret => ENV['sessionKey']
end

use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
end

get '/' do
  uid = session[:uid] || request.cookies['uid']
  if(uid.nil?)
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

  user = User.where(:provider => session[:provider], :uid=> session[:uid].to_i).first()
  user.tasks.select {|t| t.expires < Time.now}.each{|t| t.reset()}
  user.save()

  @task = user.tasks.take(3)

  while @task.length < 3
    emptyTask = Task.new(:description => "Enter Task", :time_type => 0)
    user.tasks <<  emptyTask
    user.save()
    @task.push(emptyTask)
  end

  @task.to_json
end

put '/tasks/:id' do
  content_type :json
  user = User.where(:provider => session[:provider], :uid=> session[:uid].to_i).first()
  updateTask = JSON.parse(request.body.read)

  task = user.tasks.select {|t| t.id == BSON::ObjectId.from_string(params[:id])}.first()
  task.description = updateTask['description']
  task.completed = updateTask['completed']

  user.save()
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

  redirect '/'
end