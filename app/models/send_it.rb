require 'httparty'

class SendIt

  def self.send_mail template, params = {}    
    if Rails.application.config.send_it[:test_mode]
      Rails.logger.info "Received request to send mail: template = #{template}, params = #{params}"
    else
      begin
        url = "#{Rails.application.config.send_it[:url]}/send/#{template}"
        Rails.logger.info "Sending mail request to SendIt: URL = #{url}, template = #{template}"

        default_params = {
          :from           => Rails.application.config.send_it[:from],
          :priority       => 'now',
          :subject_prefix => Rails.application.config.send_it[:subject_prefix]
        }

        response = HTTParty.post url, {
          :body => default_params.deep_merge(params).to_json,
          :headers => { 'Content-Type' => 'application/json' }
        }

        unless response.code == 200
          Rails.logger.error "SendIt responded with HTTP #{response.code}"
          raise "Error communicating with SendIt"
        end
      rescue
        Rails.logger.error "Error sending mail: template = #{template}\n#{params}"
        raise
      end
    end
  end

  def self.send_alert_mail params
    send_mail 'alert_results', {
      :catalog_url => "#{Rails.application.config.find_it[:url]}/catalog/"
    }.deep_merge(params)
  end
end
