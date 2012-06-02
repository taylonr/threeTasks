class User
  include MongoMapper::Document

  key :provider, String
  key :uid, Integer
  key :username, String
end