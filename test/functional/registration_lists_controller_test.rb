require 'test_helper'

class RegistrationListsControllerTest < ActionController::TestCase
  setup do
    @registration_list = registration_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:registration_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create registration_list" do
    assert_difference('RegistrationList.count') do
      post :create, registration_list: { event: @registration_list.event }
    end

    assert_redirected_to registration_list_path(assigns(:registration_list))
  end

  test "should show registration_list" do
    get :show, id: @registration_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @registration_list
    assert_response :success
  end

  test "should update registration_list" do
    put :update, id: @registration_list, registration_list: { event: @registration_list.event }
    assert_redirected_to registration_list_path(assigns(:registration_list))
  end

  test "should destroy registration_list" do
    assert_difference('RegistrationList.count', -1) do
      delete :destroy, id: @registration_list
    end

    assert_redirected_to registration_lists_path
  end
end
