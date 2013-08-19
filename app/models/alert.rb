class Alert < ActiveRecord::Base
  attr_accessible :alert_type, :frequency, :name, :query, :user_id, :reference

  validates :alert_type, :frequency, :query, :user_id, :presence => true
  validates :frequency, :inclusion => { :in => 1..30 }

  scope :for_user, ->(user) { where(user_id: user)}
  scope :journals, ->(user) { where(user_id: user, alert_type: "journal")}
  scope :searches, ->(user) { where(user_id: user, alert_type: "search")} 
end
