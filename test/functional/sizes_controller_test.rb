require 'test_helper'

class SizesControllerTest < ActionController::TestCase
  setup do
    login
    @size = sizes(:john_doe)
  end

  test "should show size" do
    get :show
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should update size" do
    put :update, size: @size.attributes
    assert_redirected_to sizes_path
  end
end
