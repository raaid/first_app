require 'test_helper'

class AuthenticationsControllerTest < ActionController::TestCase
  setup do
    @authentication = authentications(:one)
  end

  test "should get index" do
    login
    get :index
    assert_response :success
    assert_not_nil assigns(:authentications)
  end

  test "should show authentication" do
    login
    get :show, id: @authentication
    assert_response :redirect
  end
end
