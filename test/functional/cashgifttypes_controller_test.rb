require 'test_helper'

class CashgifttypesControllerTest < ActionController::TestCase
  setup do
    @cashgifttype = cashgifttypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cashgifttypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cashgifttype" do
    assert_difference('Cashgifttype.count') do
      post :create, cashgifttype: { cgp_content_type: @cashgifttype.cgp_content_type, cgp_file_name: @cashgifttype.cgp_file_name, cgp_file_size: @cashgifttype.cgp_file_size, description: @cashgifttype.description, goal: @cashgifttype.goal, shown: @cashgifttype.shown, title: @cashgifttype.title, user_id: @cashgifttype.user_id }
    end

    assert_redirected_to cashgifttype_path(assigns(:cashgifttype))
  end

  test "should show cashgifttype" do
    get :show, id: @cashgifttype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cashgifttype
    assert_response :success
  end

  test "should update cashgifttype" do
    put :update, id: @cashgifttype, cashgifttype: { cgp_content_type: @cashgifttype.cgp_content_type, cgp_file_name: @cashgifttype.cgp_file_name, cgp_file_size: @cashgifttype.cgp_file_size, description: @cashgifttype.description, goal: @cashgifttype.goal, shown: @cashgifttype.shown, title: @cashgifttype.title, user_id: @cashgifttype.user_id }
    assert_redirected_to cashgifttype_path(assigns(:cashgifttype))
  end

  test "should destroy cashgifttype" do
    assert_difference('Cashgifttype.count', -1) do
      delete :destroy, id: @cashgifttype
    end

    assert_redirected_to cashgifttypes_path
  end
end
