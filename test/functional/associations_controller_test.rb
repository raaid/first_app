require 'test_helper'

class AssociationsControllerTest < ActionController::TestCase
  setup do
    login
    @association = associations(:john_friends_joe)
  end

  #test "should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:associations)
  #end

  test "should create association" do
    assert_difference('Association.count') do
      post :create, association: { user_id: users(:joe_blow), contact_id: users(:jane_doe), status: "accepted" }
    end

    assert_redirected_to associations_path
  end

  test "should create notification" do
    assert_difference('Notification.count') do
      post :create, association: { user_id: users(:joe_blow), contact_id: users(:jim_loner) }
    end
    assert_redirected_to associations_path
  end

  #test "should show association" do
  #  get :show, id: @association
  #  assert_response :success
  #end

  test "should destroy association" do
    assert_difference('Association.count', -2) do
      delete :destroy, id: @association
    end

    assert_redirected_to associations_path
  end
end
