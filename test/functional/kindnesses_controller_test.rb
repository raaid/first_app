require 'test_helper'

class KindnessesControllerTest < ActionController::TestCase
  setup do
    login
    @kindness = kindnesses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kindnesses_given)
    assert_not_nil assigns(:kindnesses_received)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kindness" do
    assert_difference('Kindness.count') do
      post :create, kindness: @kindness.attributes, recipients: [users(:john_doe).id]
    end

    assert_redirected_to kindnesses_path
  end

  test "should show kindness" do
    get :show, id: @kindness
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kindness
    assert_response :success
  end

  test "should update kindness" do
    put :update, id: @kindness, kindness: @kindness.attributes
    assert_redirected_to kindnesses_path
  end

  test "should destroy kindness" do
    assert_difference('Kindness.count', -1) do
      delete :destroy, id: @kindness
    end

    assert_redirected_to kindnesses_path
  end
end
