require 'httparty'

class User
  extend ActiveModel::Naming
  include ActiveModel::Conversion  
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity
  include HTTParty

  base_uri Rails.application.config.user[:url]

  attr_accessor :id
  validates_presence_of :id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    @body = get_user || {}    
  end

  def email    
    @body['email'] 
  end

  def type
    @body['dtu'].nil? ? "dtupub" : "dtu"
  end

  def persisted?
    false
  end

  private

  def get_user    
    begin
      response = self.class.get("/rest/users/#{@id}.json")
      if response.success?        
        body = ActiveSupport::JSON.decode(response.body)
      else
        Rails.logger.error "Could not get user with id #{@id}: #{response.inspect}"
      end
    rescue Timeout::Error
      Rails.logger.error "Could not get user with id #{@id}: Auth service timed out"
    rescue Exception => e
      Rails.logger.error "Could not get user with id #{@id}: #{e.class} #{e.message}"
    end
    body
  end

end