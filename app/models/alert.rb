
class Alert < ActiveRecord::Base
  has_many :alert_stats, dependent: :destroy

  # frequency unit is days
  attr_accessible :alert_type, :frequency, :name, :query, :user_id, :reference

  validates :alert_type, :frequency, :query, :user_id, :presence => true
  validates :frequency, :inclusion => { :in => 1..30 }

  # used by API
  scope :for_user, ->(user) { where(user_id: user)}
  scope :journals, ->(user) { where(user_id: user, alert_type: "journal")}
  scope :searches, ->(user) { where(user_id: user, alert_type: "search")}  

  # used by AlertRunner
  def self.alerts_to_run
    # alerts that has not been run before
    query = "SELECT * FROM alerts WHERE NOT EXISTS (SELECT * FROM alert_stats WHERE alert_id=alerts.id) AND created_at < #{self.alert_time_filter}"
    # alerts that has been run before and is within the time range
    query << " UNION SELECT * FROM alerts WHERE (SELECT MAX(last_run) FROM alert_stats WHERE alert_id=alerts.id) < #{self.alert_time_filter}";    
    Alert.find_by_sql(query)        
  end

  def last_run
    if alert_stats.length > 0
      alert_stats.last.last_run
    else      
      created_at
    end
  end

  def solr_query
    if alert_type == "journal"
      query
    else
      solr_params = {}
      query_params = YAML::load(query) 

      # standard query
      solr_params[:q] = query_params[:q] if query_params.key?(:q)
      solr_params[:q] ||= "*:*"

      # facet filters
      if query_params.key?(:f)
        solr_params[:fq] = []
        query_params[:f].each do |facet, value|
          if value.is_a? Array
            value.each {|v| solr_params[:fq] << "#{facet}:#{v}" }
          else
            solr_params[:fq] << "#{facet}:#{value}"
          end
        end
      end

      # date range query
      if query_params.key?(:range)
        solr_params[:fq] = [] unless solr_params.key?(:fq)      
        range = query_params[:range].first
        solr_params[:fq] << "#{range.first}:[#{range.last[:begin]} TO #{range.last[:end]}]"
      end

      # search field
      if query_params.key?(:search_field)
        solr_params[:q] = add_search_field(query_params[:search_field], solr_params[:q])
      end

      solr_params
    end
  end

  def blacklight_query
    if alert_type == "journal"      
      "#{Rails.application.config.find_it[:url]}?q=issn:#{query}"
    else
      query_params = YAML::load(query) 

      if query_params.key?(:search_field)
        query_params[:q] = add_search_field(query_params[:search_field], query_params[:q])
      end

      params = query_params.select {|k| ["q", "f", "range"].include? k }
      "#{Rails.application.config.find_it[:url]}/#{query_params[:locale]}/#{query_params[:controller]}?#{params.to_query}"
    end
  end

  def query_text
    query_text = []
    if alert_type == "search"
      query_params = YAML::load(query)

      query = ""
      if query_params.key?(:search_field) && query_params[:search_field] != "all_fields"
        query <<  I18n.t("search_field_labels.#{query_params[:search_field]}")
        query << ":"
      end

      query_text << (query << query_params[:q]) if query_params.key?(:q)
      
      if query_params.key?(:f)
        query_params[:f].each do |facet|
          label = I18n.t("facet_field_labels.#{facet.first}")
          query_text << "#{label}:#{facet.last.first}"
        end
      end
      
      if query_params.key?(:range)        
        label = I18n.t("facet_field_labels.#{query_params[:range].first.first}")
        range = query_params[:range].first.last
        query_text << "#{label}:#{range['begin']} - #{range['end']}"        
      end
    end

    query_text.join(", ")
  end

  private

  def add_search_field(search_field, q)    
    # note that also numbers and journal_title is defined in toshokan catalog controller
    # but not in solr config      
    if ["author", "title", "subject"].include?(search_field)
      q = "{!qf=#{search_field}_qf}#{q}"
    end
    q
  end

  def self.alert_time_filter    
    # non SQL standard syntax: for SQLite or PostgreSQL
    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      "datetime(CURRENT_TIMESTAMP, '-' || frequency || ' days')"
    else
      "(CURRENT_TIMESTAMP - interval frequency || ' days')"
    end
  end
end