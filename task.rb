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