require 'spec_helper'

describe Alert do

  describe ".alerts_to_run" do

    describe "search alerts" do

      before do
        FactoryGirl.create(:new_search_alert1)
        FactoryGirl.create(:new_search_alert2)
        FactoryGirl.create(:not_ready_search_alert)
        FactoryGirl.create(:ready_search_alert)
      end

      subject do
        Alert.alerts_to_run
      end

      it { should have(2).items }
      it { should include ( an_alert_named "new 1" )}
      it { should_not include ( an_alert_named "new 2" )}
      it { should include ( an_alert_named "should run" )}
      it { should_not include ( an_alert_named "should not run" )}
    end

    describe "journal alerts" do

      before do
        FactoryGirl.create(:journal_alert_issn1a)
        FactoryGirl.create(:journal_alert_issn1b)
        FactoryGirl.create(:journal_alert_issn2)
      end

      subject do
        Alert.alerts_to_run
      end

      it { should have(2).items }
    end
  end

  describe "#last_run" do
    before do
      @alert1 = FactoryGirl.create(:new_search_alert1)
      @alert2 = FactoryGirl.create(:ready_search_alert)      
    end

    it "sets a last run date for an alert that has not run before" do      
      @alert1.last_run.at_beginning_of_day.should eq 9.days.ago.at_beginning_of_day
    end

    it "sets the last run date for an alert that has been run before" do
      @alert2.last_run.at_beginning_of_day.should eq (DateTime.current - 2.months).at_beginning_of_day
    end
  end

  describe "#solr_query" do

    it "creates a default query parameter" do
      alert = FactoryGirl.create(:alert_no_query)            
      alert.solr_query[:q].should eq "*:*"      
    end

    it "creates a plain query parameter" do
      alert = FactoryGirl.create(:alert_plain_query)      
      alert.solr_query[:q].should eq "test"
    end

    it "creates a filter query parameter" do
      alert = FactoryGirl.create(:alert_facet_query)
      alert.solr_query[:fq].first.should eq "{!term f=format}:article"      
    end

    it "creates range filter query parameter" do
      alert = FactoryGirl.create(:alert_range_query)
      alert.solr_query[:fq].should include("pub_date_tsort:[2010 TO 2011]")      
    end

    it "creates multiple filter query parameters" do
      alert = FactoryGirl.create(:alert_multi_facet_query)
      alert.solr_query[:fq].should include "{!term f=format}:article"
      alert.solr_query[:fq].should include "{!term f=author_facet}:Lee"
    end

    it "prepends a search query field to the query" do
      alert = FactoryGirl.create(:alert_search_field)
      alert.solr_query[:q].should eq "{!qf=author_qf}Dijkstra, Edsger W."
    end

    it "does not alter the query for journal alerts" do
      alert = FactoryGirl.create(:journal_alert_issn1a)
      alert.solr_query.should eq "14764687"
    end
  end

  describe "#blacklight_query" do

    it "creates a search url from a plain query" do
      alert = FactoryGirl.create(:alert_plain_query)
      alert.blacklight_query.should match /en\/catalog\?q=test/
    end

    it "creates a search url with only filters" do
      alert = FactoryGirl.create(:alert_no_query)                 
      alert.blacklight_query.should match /#{Regexp.escape("f%5Bformat%5D%5B%5D=article")}/
    end

    it "creates a search url with filter and query parameters" do
      alert = FactoryGirl.create(:alert_facet_query)
      alert.blacklight_query.should match /f%5Bformat%5D%5B%5D=article&q=test/            
    end

    it "creates a search url with range filter query parameter" do
      alert = FactoryGirl.create(:alert_range_query)
      alert.blacklight_query.should match /range%5Bpub_date_tsort%5D%5Bbegin%5D=2010&range%5Bpub_date_tsort%5D%5Bend%5D=2011/            
    end

    it "creates a search url with multiple filter query parameters" do
      alert = FactoryGirl.create(:alert_multi_facet_query)
      alert.blacklight_query.should match /#{Regexp.escape("f%5Bauthor_facet%5D%5B%5D=Lee&f%5Bformat%5D%5B%5D=article&f%5Bjournal_title_facet%5D%5B%5D=Polish+Journal+of+Cardiology")}/
    end

    it "create a search url with a search field" do
      alert = FactoryGirl.create(:alert_search_field)
      alert.blacklight_query.should match /#{Regexp.escape(CGI.escape "{!qf=author_qf}Dijkstra, Edsger W.")}/
    end

    it "creates a search url for a journal alert" do
      alert = FactoryGirl.create(:journal_alert_issn1a)
      alert.blacklight_query.should match /q=issn:14764687/      
    end
  end

  describe "#query_text" do

    it "creates a query text from a plain query" do
      alert = FactoryGirl.create(:alert_plain_query)
      alert.query_text.should eq "test"
    end

    it "creates a query text from a query with only filters" do
      alert = FactoryGirl.create(:alert_no_query)                 
      alert.query_text.should eq "Type:article"
    end

    it "creates a a query text with filter and query parameters" do
      alert = FactoryGirl.create(:alert_facet_query)
      alert.query_text.should eq "test, Type:article"
    end

    it "creates a query text with range filter query parameter" do
      alert = FactoryGirl.create(:alert_range_query)
      alert.query_text.should eq "test, Type:article, Publication Year:2010 - 2011"
    end

    it "creates a query text with multiple filter query parameters" do
      alert = FactoryGirl.create(:alert_multi_facet_query)
      alert.query_text.should eq "test, Author:Lee, Type:article, Journal Title:Polish Journal of Cardiology, Publication Year:2010 - 2011"      
    end

    it "create a query text with a search field" do
      alert = FactoryGirl.create(:alert_search_field)
      alert.query_text.should eq "Author:Dijkstra, Edsger W."
    end
  end
end