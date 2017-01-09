
require 'rsolr'

class Solr

  def initialize
    @params = {
      :rows => Rails.application.config.solr[:rows],
      :fl => 'title_ts, cluster_id_ss, format, author_ts, pub_date_tis, journal_title_ts, journal_vol_ssf, journal_issue_ssf, journal_page_ssf',
      :facet => false
    }
  end

  def query(query, type, user_type, date_from, date_to)

    filter_queries = [
      "alert_timestamp_dt:[#{date_from.to_time.iso8601} TO #{date_to.to_time.iso8601}]",
      "access_ss:#{user_type}",
      "pub_date_tis:[#{((DateTime.now - 1.year).strftime '%Y').to_i} TO *]"
    ]

    params = {}
    if type == "journal"
      params[:q] = "issn_ss:#{query}"
      # only include articles in the range current year - 1 to current year + 1
      # to avoid inclusion of back logs
      params[:fq] = filter_queries
      params[:sort] = "journal_vol_tsort desc, journal_issue_tsort desc, journal_page_start_tsort asc"
    else
      params = query
      params[:fq] = [] unless params.key? :fq
      params[:fq].concat(filter_queries)
    end
    params = @params.deep_merge(params)
    Rails.logger.debug("Sending query to solr with params #{params.inspect}")

    send_query(params)
  end

  def max_alert_date
    response = send_query({
      :q => "*:*",
      :rows => 1,
      :sort => "alert_timestamp_dt desc",
      :fl => "alert_timestamp_dt",
      :facet => false,
    })
    max_alert_date = DateTime.current
    if response['response']['numFound'] > 1
      max_alert_date = response['response']['docs'].first['alert_timestamp_dt'].to_datetime
    else
      Rails.logger.warn "Could not find max alert date in Solr"
    end
    max_alert_date
  end

  private

  def send_query(params)
    connection.get 'toshokan', params: params
  end

  def connection
    @solr ||= RSolr.connect(url: Rails.application.config.solr[:url], read_timeout: 10*60, open_timeout: 10*60)
  end

end
