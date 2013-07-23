require 'spec_helper'

describe AlertStatsController do

  before do
    @alert = FactoryGirl.create(:alert1)
  end

  describe "#index" do
    before do
      get :index, :alert_id => @alert.id
      response.body
    end

    it { response.response_code.should == 200 }   
  end
end