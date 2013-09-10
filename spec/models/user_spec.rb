require 'spec_helper'

describe User do

  context "active model" do

    before do
      stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_return(:status => 200, :body => "", :headers => {})
    end

    it_behaves_like "ActiveModel"
  end

  let(:dtu_user) {
    body = "{\"authenticator\":\"dtu\",\"created_at\":\"2013-08-26T07:23:36Z\",\"email\":\"test@dtic.dtu.dk\",\"first_name\":\"Jon\",\"id\":1,\"last_name\":\"Snow\",\"updated_at\":\"2013-09-09T14:32:07Z\",\"user_type_id\":3,\"user_type\":\"dtu_empl\",\"dtu\":{\"reason\":null,\"email\":\"test@dtic.dtu.dk\",\"library_access\":\"1\",\"firstname\":\"Jon\",\"lastname\":\"Snow\",\"initials\":\"josn\",\"matrikel_id\":\"1234\",\"user_type\":\"dtu_empl\",\"org_units\":[\"58\"]}}"
    stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_return(:success? => true, :body => body)
    User.new({:id => 1})
  }
  let(:public_user) {
    body = "{\"authenticator\":\"google_oauth2\",\"created_at\":\"2013-09-12T09:30:32Z\",\"email\":\"snow@gmail.com\",\"first_name\":\"Jon\",\"id\":2,\"last_name\":\"Snow\",\"updated_at\":\"2013-09-12T09:30:32Z\",\"user_type_id\":2,\"user_type\":\"private\"}"
    stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_return(:success? => true, :body => body)
    User.new({:id => 2})
  }

  let(:not_found_user1) {
    stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_return(:success? => false, :message => "Failure", :code => 500)
    User.new({:id => 1})
  }
  let(:not_found_user2) {
    stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_raise(TimeoutError)
    User.new({:id => 1})
  }
  let(:not_found_user3) {
    stub_request(:get, /#{Rails.application.config.user[:url]}.*/).to_return(:success? => false, :message => "Failure", :code => 404)
    User.new({:id => 1})
  }

  # public user

  describe "#email" do
    it "returns an email address for a dtu user" do      
      dtu_user.email.should eq "test@dtic.dtu.dk"
    end
    it "returns an email address for a public user" do      
      public_user.email.should eq "snow@gmail.com"
    end
    it "returns nil if user could not be fetched" do
      not_found_user1.email.should be_nil
      not_found_user2.email.should be_nil
      not_found_user3.email.should be_nil
    end
  end

  describe "#type" do
    it "returns a dtu type for a dtu user" do
      dtu_user.type.should eq "dtu"
    end
    it "returns a public type for a public user" do
      public_user.type.should eq "dtupub"
    end
    it "returns public type if user could not be set" do
      not_found_user1.type.should eql "dtupub"
      not_found_user2.type.should eql "dtupub"
      not_found_user3.type.should eql "dtupub"
    end
  end

end