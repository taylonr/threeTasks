require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'handler'

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