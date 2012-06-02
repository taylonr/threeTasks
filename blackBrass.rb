require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'task'
require 'user'

configure :test do
  set :twitterKey => 'Uwk8eu2sGU8HGhzvCK8aA'
  set :twitterSecret => '78vXIZQ31n5lWELfPNnnqWZGwgZjzvoZorqzPPRmSSA'

  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
  enable :sessions
end

configure :development do
  set :twitterKey => 'our1xG0LeJcCXLj0MAMLg'
  set :twitterSecret => 'quMYVPmoZoW8FGlfkaAkRfHwq68YC7UtD02OMDLYg'

  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
  enable :sessions
end

use OmniAuth::Builder do
  provider :twitter, settings.twitterKey, settings.twitterSecret
end

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/tasks' do
  content_type :json
  Task.delete_all(:expires => {:$lt => Time.now})

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
  task.user_id = session[:user_id]
  task.save()
  task.to_json
end

get '/auth/twitter/callback' do
  auth = request.env['omniauth.auth']
  user = User.first(:provider => auth["provider"], :uid => auth["uid"]) || User.create(:provider => auth["provider"], :uid => auth["uid"])
  #auth["user_info"]["name"]
  session[:user_id] = user.id
  redirect '/'
end