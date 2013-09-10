require 'test_helper'

class AffiliateSubscriptionsControllerTest < ActionController::TestCase
  setup do
    @affiliate_subscription = affiliate_subscriptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:affiliate_subscriptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create affiliate_subscription" do
    assert_difference('AffiliateSubscription.count') do
      post :create, affiliate_subscription: { expiry: @affiliate_subscription.expiry }
    end

    assert_redirected_to affiliate_subscription_path(assigns(:affiliate_subscription))
  end

  test "should show affiliate_subscription" do
    get :show, id: @affiliate_subscription
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @affiliate_subscription
    assert_response :success
  end

  test "should update affiliate_subscription" do
    put :update, id: @affiliate_subscription, affiliate_subscription: { expiry: @affiliate_subscription.expiry }
    assert_redirected_to affiliate_subscription_path(assigns(:affiliate_subscription))
  end

  test "should destroy affiliate_subscription" do
    assert_difference('AffiliateSubscription.count', -1) do
      delete :destroy, id: @affiliate_subscription
    end

    assert_redirected_to affiliate_subscriptions_path
  end
end
