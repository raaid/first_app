require 'test_helper'

class AffiliateReferralsControllerTest < ActionController::TestCase
  setup do
    @affiliate_referral = affiliate_referrals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:affiliate_referrals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create affiliate_referral" do
    assert_difference('AffiliateReferral.count') do
      post :create, affiliate_referral: {  }
    end

    assert_redirected_to affiliate_referral_path(assigns(:affiliate_referral))
  end

  test "should show affiliate_referral" do
    get :show, id: @affiliate_referral
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @affiliate_referral
    assert_response :success
  end

  test "should update affiliate_referral" do
    put :update, id: @affiliate_referral, affiliate_referral: {  }
    assert_redirected_to affiliate_referral_path(assigns(:affiliate_referral))
  end

  test "should destroy affiliate_referral" do
    assert_difference('AffiliateReferral.count', -1) do
      delete :destroy, id: @affiliate_referral
    end

    assert_redirected_to affiliate_referrals_path
  end
end
