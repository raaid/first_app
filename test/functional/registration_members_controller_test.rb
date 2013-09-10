require 'test_helper'

class RegistrationMembersControllerTest < ActionController::TestCase
  setup do
    @registration_member = registration_members(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:registration_members)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create registration_member" do
    assert_difference('RegistrationMember.count') do
      post :create, registration_member: { email: @registration_member.email, name: @registration_member.name, registration_list: @registration_member.registration_list }
    end

    assert_redirected_to registration_member_path(assigns(:registration_member))
  end

  test "should show registration_member" do
    get :show, id: @registration_member
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @registration_member
    assert_response :success
  end

  test "should update registration_member" do
    put :update, id: @registration_member, registration_member: { email: @registration_member.email, name: @registration_member.name, registration_list: @registration_member.registration_list }
    assert_redirected_to registration_member_path(assigns(:registration_member))
  end

  test "should destroy registration_member" do
    assert_difference('RegistrationMember.count', -1) do
      delete :destroy, id: @registration_member
    end

    assert_redirected_to registration_members_path
  end
end
