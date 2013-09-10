require 'test_helper'

class WeddingeventsControllerTest < ActionController::TestCase
  setup do
    @weddingevent = weddingevents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weddingevent" do
    assert_difference('Weddingevent.count') do
      post :create, weddingevent: { date: @weddingevent.date, description: @weddingevent.description, details: @weddingevent.details, event_photo_name: @weddingevent.event_photo_name, event_photo_size: @weddingevent.event_photo_size, event_photo_type: @weddingevent.event_photo_type, has_list: @weddingevent.has_list, list_id: @weddingevent.list_id, location: @weddingevent.location, name: @weddingevent.name }
    end

    assert_redirected_to weddingevent_path(assigns(:weddingevent))
  end

  test "should show weddingevent" do
    get :show, id: @weddingevent
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @weddingevent
    assert_response :success
  end

  test "should update weddingevent" do
    put :update, id: @weddingevent, weddingevent: { date: @weddingevent.date, description: @weddingevent.description, details: @weddingevent.details, event_photo_name: @weddingevent.event_photo_name, event_photo_size: @weddingevent.event_photo_size, event_photo_type: @weddingevent.event_photo_type, has_list: @weddingevent.has_list, list_id: @weddingevent.list_id, location: @weddingevent.location, name: @weddingevent.name }
    assert_redirected_to weddingevent_path(assigns(:weddingevent))
  end

  test "should destroy weddingevent" do
    assert_difference('Weddingevent.count', -1) do
      delete :destroy, id: @weddingevent
    end

    assert_redirected_to weddingevents_path
  end
end
