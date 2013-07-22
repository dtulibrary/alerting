require 'test_helper'

class AlertsControllerTest < ActionController::TestCase
  setup do
    @alert = alerts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alerts)
  end

  test "should create alert" do
    assert_difference('Alert.count') do
      post :create, alert: { alert_type: @alert.alert_type, frequency: @alert.frequency, name: @alert.name, query: @alert.query, user: @alert.user }
    end

    assert_response 201
  end

  test "should show alert" do
    get :show, id: @alert
    assert_response :success
  end

  test "should update alert" do
    put :update, id: @alert, alert: { alert_type: @alert.alert_type, frequency: @alert.frequency, name: @alert.name, query: @alert.query, user: @alert.user }
    assert_response 204
  end

  test "should destroy alert" do
    assert_difference('Alert.count', -1) do
      delete :destroy, id: @alert
    end

    assert_response 204
  end
end
