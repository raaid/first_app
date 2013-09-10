require 'test_helper'

class WidgetProfilesControllerTest < ActionController::TestCase
  setup do
    @widget_profile = widget_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:widget_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create widget_profile" do
    assert_difference('WidgetProfile.count') do
      post :create, widget_profile: { events_background: @widget_profile.events_background, tickets_background: @widget_profile.tickets_background, user_id: @widget_profile.user_id }
    end

    assert_redirected_to widget_profile_path(assigns(:widget_profile))
  end

  test "should show widget_profile" do
    get :show, id: @widget_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @widget_profile
    assert_response :success
  end

  test "should update widget_profile" do
    put :update, id: @widget_profile, widget_profile: { events_background: @widget_profile.events_background, tickets_background: @widget_profile.tickets_background, user_id: @widget_profile.user_id }
    assert_redirected_to widget_profile_path(assigns(:widget_profile))
  end

  test "should destroy widget_profile" do
    assert_difference('WidgetProfile.count', -1) do
      delete :destroy, id: @widget_profile
    end

    assert_redirected_to widget_profiles_path
  end
end
