class Alert < ActiveRecord::Base
  attr_accessible :alert_type, :frequency, :name, :query, :user

  validates :alert_type, :frequency, :query, :user, :presence => true
  validates :frequency, :inclusion => { :in => 1..30 }
end
