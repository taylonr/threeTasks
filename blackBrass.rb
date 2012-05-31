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
  @task = Task.limit(3)
  @task.to_json
end

post '/tasks' do
  content_type :json
  task = Task.new(JSON.parse request.body.read)
  task.save()
  task.to_json
end

put '/tasks/:id' do
  content_type :json
  task = Task.find_by_id(params[:id])
  task.update_attributes!(JSON.parse request.body.read)
  task.save()
  task.to_json
end