class Alert < ActiveRecord::Base
  attr_accessible :alert_type, :frequency, :name, :query, :user
end
