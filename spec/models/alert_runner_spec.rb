require 'spec_helper'

describe AlertRunner do

  before do
    user = double('user')
    User.stub(:new) { user }
    user.stub(:email).and_return('test@dtic.dtu.dk')  
    user.stub(:type).and_return('dtu')  

    stub_request(:get, /#{Rails.application.config.solr[:url]}.*/).with(:query => hash_including({"fl" => "alert_timestamp_dt"})).to_return(File.new("spec/fixtures/solr_max_alert_date.txt"))
  end

  describe "#run_alerts" do

    before do
      stub_request(:get, /#{Rails.application.config.solr[:url]}.*/).with(:query => hash_including({"rows" => "50"})).to_return(File.new("spec/fixtures/solr_issn.txt"))    

      FactoryGirl.create(:journal_alert_issn1a)      
      FactoryGirl.create(:journal_alert_issn2)
      FactoryGirl.create(:new_search_alert1)
      FactoryGirl.create(:not_ready_search_alert)
      FactoryGirl.create(:ready_search_alert)

      @sent = AlertRunner.run_alerts
    end

    it "sends the correct number of alert mails" do
      @sent.should be 4
    end

    it "updates the alert stats for the alerts" do
      Alert.all.all? {|alert| alert.alert_stats.length > 0}.should be_true
    end

    it "sets the hit count" do      
      Alert.first.alert_stats.count.should be > 0
    end
  end
end