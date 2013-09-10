require 'test_helper'

class TicketTypesControllerTest < ActionController::TestCase
  setup do
    @ticket_type = ticket_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticket_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticket_type" do
    assert_difference('TicketType.count') do
      post :create, ticket_type: { event: @ticket_type.event, groupable: @ticket_type.groupable, name: @ticket_type.name, price: @ticket_type.price, sell_from: @ticket_type.sell_from, sell_to: @ticket_type.sell_to }
    end

    assert_redirected_to ticket_type_path(assigns(:ticket_type))
  end

  test "should show ticket_type" do
    get :show, id: @ticket_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ticket_type
    assert_response :success
  end

  test "should update ticket_type" do
    put :update, id: @ticket_type, ticket_type: { event: @ticket_type.event, groupable: @ticket_type.groupable, name: @ticket_type.name, price: @ticket_type.price, sell_from: @ticket_type.sell_from, sell_to: @ticket_type.sell_to }
    assert_redirected_to ticket_type_path(assigns(:ticket_type))
  end

  test "should destroy ticket_type" do
    assert_difference('TicketType.count', -1) do
      delete :destroy, id: @ticket_type
    end

    assert_redirected_to ticket_types_path
  end
end
