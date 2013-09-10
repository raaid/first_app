require 'test_helper'

class RedemptionsControllerTest < ActionController::TestCase
  setup do
    login
    @redemption = redemptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:redemptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create redemption" do
    assert_difference('Redemption.count') do
      post :create, redemption: @redemption.attributes
    end

    assert_redirected_to redemption_path(assigns(:redemption))
  end

  test "should show redemption" do
    get :show, id: @redemption
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @redemption
    assert_response :success
  end

  test "should update redemption" do
    put :update, id: @redemption, redemption: @redemption.attributes
    assert_redirected_to redemption_path(assigns(:redemption))
  end

  test "should destroy redemption" do
    assert_difference('Redemption.count', -1) do
      delete :destroy, id: @redemption
    end

    assert_redirected_to redemptions_path
  end
end
