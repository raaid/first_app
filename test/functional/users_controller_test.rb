require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john_doe)
  end

  test "should get new" do
    logout
    get :new
    assert_response :success
  end

  test "should create user" do
    logout
    assert_difference('User.count') do
      # we can't use a user from a fixture here, because they are all in the DB already and email must be unique.
      post :create, user: {fname: 'test', lname: 'testerson', email: "test@example.org", password: "testpass"}
    end

    assert_redirected_to root_path
  end

  test "should show user" do
    login
    get :show, id: @user
    assert_response :success
  end

  test "should show profile" do
    login
    get :profile, id: @user
    assert_response :success

    # Sizes should be shown on the profile.
    assert_select '#show_sizes', 1
  end

  test "should get edit" do
    login
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    login
    put :update, id: @user, user: @user.attributes
    assert_redirected_to profile_path
  end

  test "should destroy user" do
    login
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to root_path
  end
end
