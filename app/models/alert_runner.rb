
class AlertRunner

  def self.run_alerts

    Rails.logger.info "Start processesing alerts"
    alert_mails_sent = 0
    
    begin

      solr = Solr.new

      # only search for new stuff between last search date and the highest alert date found in the index,
      # in order to avoid missing articles with alert dates that are within the current
      # time frame, but which hasn't been indexed yet
      run_to = solr.max_alert_date

      Alert.alerts_to_run.each do |alert|       

        # Notice journal alerts are not grouped together (which would reduce metastore searches)
        # since the query needs to limited by the users access rights (user role could 
        # change over time and should not be stored in the alerting app) and since it
        # limits flexibility wrt setting frequency on individual alerts

        user = User.new({:id => alert.user_id})
        
        if user.email.nil?  
          Rails.logger.warn "Email missing for #{alert.inspect}"
        else        
          last_run = alert.last_run        
          response = solr.query(alert.solr_query, alert.alert_type, user.type, last_run, run_to)
          hit_count = response['response']['numFound']
          blacklight_query = alert.blacklight_query        

          update = true
          if hit_count > 0          
            begin             
              params = {
                :to => user.email,
                :hit_count => hit_count,
                :title => (alert.alert_type == "journal" ? alert.name : alert.query_text),
                :type => alert.alert_type,
                :last_run => last_run.strftime('%Y-%m-%d'),
                :response => response['response']['docs'],
                :query_url => blacklight_query
              }
              SendIt.send_alert_mail(params)                
              alert_mails_sent += 1
            rescue Exception => e
              update = false
              Rails.logger.warn "Mail for alert #{alert.inspect} could not be send: #{e.inspect}"
            end
          end
          
          if update
            alert.alert_stats.build(:count => hit_count, :last_run => run_to)
            alert.save
          end
          
        end
      end

    rescue Exception => e
      Rails.logger.error "Running alerts failed with #{e.message}"        
      Rails.logger.error e.backtrace.join("\n")
    end

    Rails.logger.info "End processesing alerts. #{alert_mails_sent} alerts sent."

    alert_mails_sent
  end

end