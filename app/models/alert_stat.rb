class AlertStat < ActiveRecord::Base
  belongs_to :alert
  attr_accessible :count, :last_run, :created_at
end
