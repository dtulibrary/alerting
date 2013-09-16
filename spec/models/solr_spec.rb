# -*- encoding : utf-8 -*-

require 'spec_helper'

describe Solr do

  let(:solr) { Solr.new }

  describe "#query" do

    it "fetches a solr response for a journal query" do
      stub_request(:get, /#{Rails.application.config.solr[:url]}.*/).to_return(File.new("spec/fixtures/solr_issn.txt"))
      response = solr.query('14764687', "journal", "dtupub", DateTime.new(2013, 8, 5, 0, 0, 0), DateTime.new(2013, 8, 12, 0, 0, 0))
      response['response']['numFound'].to_i.should == 83
    end

    it "fetches a solr response for a search query" do
      alert = Alert.new
      alert.alert_type = "search"
      alert.query = "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        q: test
        search_field: all_fields
        utf8: ✓
        action: index
        controller: catalog
        locale: en
        f: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          author_facet:
          - ! \"Lee\"
          format:
          - article
          journal_title_facet:
          - Polish Journal of Cardiology
        t: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          test: ✓
        range: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          pub_date_tsort: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
            begin: '2010'
            end: '2011'"
      stub_request(:get, /#{Rails.application.config.solr[:url]}.*/).to_return(File.new("spec/fixtures/solr_search.txt"))
      response = solr.query(alert.solr_query, "search", "dtupub", DateTime.new(2013, 8, 5, 0, 0, 0), DateTime.new(2013, 8, 12, 0, 0, 0))
      response['response']['numFound'].to_i.should == 12692
    end
  end

  describe "#max_alert_date" do

    it "fetches max alert date" do
      stub_request(:get, /#{Rails.application.config.solr[:url]}.*/).to_return(File.new("spec/fixtures/solr_max_alert_date.txt"))
      expected_date = DateTime.new(2013, 9, 12, 22, 0, 10,'+0')
      solr.max_alert_date.should eql expected_date
    end
  end

end
