require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  setup do
    login
    @notification = notifications(:one)
    @association = associations(:the_ex_friend_request)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  #test "should get new" do
  #  get :new
  #  assert_response :success
  #end

  #test "should show notification" do
  #  get :show, id: @notification
  #  assert_response :success
  #end

  #test "should get edit" do
  #  get :edit, id: @notification
  #  assert_response :success
  #end

  #test "should update notification" do
  #  put :update, id: @notification, notification: @notification.attributes
  #  assert_redirected_to notification_path(assigns(:notification))
  #end

  test "should destroy notification" do
    assert_difference('Notification.count', -1) do
      delete :destroy, id: @notification
    end

    assert_redirected_to notifications_path
  end
end
