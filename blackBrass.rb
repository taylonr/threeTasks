require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'

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
  Task.delete_all(:expires => {:$lt => Time.now})

  @task = Task.limit(3).all
  while @task.length < 3
    emptyTask = Task.new(:description => "Enter Task", :time_type=> 0)
    emptyTask.save()
    @task.push(emptyTask)
  end
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