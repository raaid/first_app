require 'test_helper'

class TicketInstancesControllerTest < ActionController::TestCase
  setup do
    @ticket_instance = ticket_instances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticket_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticket_instance" do
    assert_difference('TicketInstance.count') do
      post :create, ticket_instance: { guest: @ticket_instance.guest, guest_email: @ticket_instance.guest_email, guest_name: @ticket_instance.guest_name, host: @ticket_instance.host, paypal_transaction_id: @ticket_instance.paypal_transaction_id, price_paid: @ticket_instance.price_paid, quantity: @ticket_instance.quantity, status: @ticket_instance.status }
    end

    assert_redirected_to ticket_instance_path(assigns(:ticket_instance))
  end

  test "should show ticket_instance" do
    get :show, id: @ticket_instance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ticket_instance
    assert_response :success
  end

  test "should update ticket_instance" do
    put :update, id: @ticket_instance, ticket_instance: { guest: @ticket_instance.guest, guest_email: @ticket_instance.guest_email, guest_name: @ticket_instance.guest_name, host: @ticket_instance.host, paypal_transaction_id: @ticket_instance.paypal_transaction_id, price_paid: @ticket_instance.price_paid, quantity: @ticket_instance.quantity, status: @ticket_instance.status }
    assert_redirected_to ticket_instance_path(assigns(:ticket_instance))
  end

  test "should destroy ticket_instance" do
    assert_difference('TicketInstance.count', -1) do
      delete :destroy, id: @ticket_instance
    end

    assert_redirected_to ticket_instances_path
  end
end
