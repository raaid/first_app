require 'test_helper'

class GiftsControllerTest < ActionController::TestCase
  setup do
    login
    @gift = gifts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gifts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gift" do
    assert_difference('Gift.count', 1) do
      post :create, gift: @gift.attributes
    end

    assert_response :redirect
  end

  test "should show gift" do
    get :show, id: @gift
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gift
    assert_response :success
  end

  test "should update gift" do
    put :update, id: @gift, gift: @gift.attributes

    assert_response :redirect
  end

  # group buy functionality moved from gifts controller
  #test "should create notification" do
  #  assert_difference('Notification.count', 1) do
  #    post :update, id: @gift, gift: @gift.attributes, participants: [users(:john_doe).id]
  #  end
  #
  #  assert_response :redirect
  #end

  test "should destroy gift" do
    assert_difference('Gift.count', -1) do
      delete :destroy, id: @gift
    end

    assert_redirected_to list_path(@gift.list)
    #assert_response :redirect
  end
end
