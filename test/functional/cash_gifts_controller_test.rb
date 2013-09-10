require 'test_helper'

class CashGiftsControllerTest < ActionController::TestCase
  setup do
    @cash_gift = cash_gifts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cash_gifts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cash_gift" do
    assert_difference('CashGift.count') do
      post :create, cash_gift: { amount: @cash_gift.amount, guest_email: @cash_gift.guest_email, guest_id: @cash_gift.guest_id, guest_name: @cash_gift.guest_name, message: @cash_gift.message, payout_fee_transaction_id: @cash_gift.payout_fee_transaction_id, payout_user_transaction_id: @cash_gift.payout_user_transaction_id, paypal_transaction_id: @cash_gift.paypal_transaction_id, status: @cash_gift.status, title: @cash_gift.title, user_id: @cash_gift.user_id }
    end

    assert_redirected_to cash_gift_path(assigns(:cash_gift))
  end

  test "should show cash_gift" do
    get :show, id: @cash_gift
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cash_gift
    assert_response :success
  end

  test "should update cash_gift" do
    put :update, id: @cash_gift, cash_gift: { amount: @cash_gift.amount, guest_email: @cash_gift.guest_email, guest_id: @cash_gift.guest_id, guest_name: @cash_gift.guest_name, message: @cash_gift.message, payout_fee_transaction_id: @cash_gift.payout_fee_transaction_id, payout_user_transaction_id: @cash_gift.payout_user_transaction_id, paypal_transaction_id: @cash_gift.paypal_transaction_id, status: @cash_gift.status, title: @cash_gift.title, user_id: @cash_gift.user_id }
    assert_redirected_to cash_gift_path(assigns(:cash_gift))
  end

  test "should destroy cash_gift" do
    assert_difference('CashGift.count', -1) do
      delete :destroy, id: @cash_gift
    end

    assert_redirected_to cash_gifts_path
  end
end
