require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'

class Task
  include MongoMapper::Document
  key :description, String
  key :user_id, ObjectId
  key :expires, Time
  key :time_type, Integer
  key :completed, Boolean
end

configure do
  mongo_uri = 'mongodb://threetaskuser:OegFFfZHlYZ559Z@ds031777.mongolab.com:31777/dev-threetasks'
  MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
  MongoMapper.database = 'dev-threetasks'
end

set :logging, true

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/tasks' do
  content_type :json
  @task = Task.all
  @task.to_json
end

post '/tasks' do
  content_type :json
  puts params.inspect
  task2 = JSON.parse request.body.read
  puts task2
  task = Task.new(task2)
  task.save()
  task.to_json
end