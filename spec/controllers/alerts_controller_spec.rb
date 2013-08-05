require 'spec_helper'

describe AlertsController, :type => :controller do

  before do
    @alert1 = FactoryGirl.create(:alert1)
    @alert2 = FactoryGirl.create(:alert2)
    @alert3 = FactoryGirl.create(:alert3)
  end

  describe "#index" do

    context "list a users alerts" do
      before do
        get :index, user: 1234
        response.body
      end

      it { response.response_code.should == 200 }
      
      it "lists all alerts for a user" do
        alerts = JSON.parse(response.body)
        alerts.all? do |a|
          a["alert"]["user"] == "1234"
        end.should be_true
        alerts.size.should == 2
      end
    end
  end

  describe "#create" do

    context "successfully add an alert" do
      before do
        request_payload = {
          :alert => {
            :name => "A new alert",
            :query => "chocolate AND cake AND ",
            :frequency => 1,
            :alert_type => "journal",
            :user => "1234"
          }
        }

        post :create, request_payload
      end

      it { response.response_code.should == 201 }

      it "adds an alert" do      
        alert = Alert.find_by_name("A new alert")
        response.body.should eql(alert.to_json)
      end
    end

    context "does not add alert with invalid data" do

      before do
        request_payload = {
          :alert => {
            :query => "chocolate AND cake",
            :frequency => 1,            
            :user => "1234"
          }
        }

        post :create, request_payload
      end

      it { response.response_code.should == 422 }
    end
  end

  describe "#show" do
    before do
      get :show, id: @alert1.id
    end

    it { response.response_code.should == 200 }
  end

  describe "#update" do
    let(:id) { @alert3.id }

    before do
      request_payload = {
        :alert => {
          :query => "issn:16838602",
          :frequency => 3,            
          :user => "4321",
          :name => "my journal alert"
        }
      }

      put :update, { id: id }.merge(request_payload)
    end

    it { response.response_code.should == 204 }

    it "should update the name" do
      alert = Alert.find_by_id(id)
      alert.name.should == "my journal alert"
    end
  end

  describe "#destroy" do
    let(:id) { @alert1.id }

    before do  
      delete :destroy, id: id
    end

    it { response.response_code.should == 204 }
    
    it "deletes the alert" do
      Alert.find_by_id(id).should be_nil
    end
  end
end
