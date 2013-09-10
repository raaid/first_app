require 'test_helper'

class WallpapersControllerTest < ActionController::TestCase
  setup do
    @wallpaper = wallpapers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wallpapers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wallpaper" do
    assert_difference('Wallpaper.count') do
      post :create, wallpaper: { event_id: @wallpaper.event_id, wallpaper_content_type: @wallpaper.wallpaper_content_type, wallpaper_file_name: @wallpaper.wallpaper_file_name, wallpaper_file_size: @wallpaper.wallpaper_file_size }
    end

    assert_redirected_to wallpaper_path(assigns(:wallpaper))
  end

  test "should show wallpaper" do
    get :show, id: @wallpaper
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wallpaper
    assert_response :success
  end

  test "should update wallpaper" do
    put :update, id: @wallpaper, wallpaper: { event_id: @wallpaper.event_id, wallpaper_content_type: @wallpaper.wallpaper_content_type, wallpaper_file_name: @wallpaper.wallpaper_file_name, wallpaper_file_size: @wallpaper.wallpaper_file_size }
    assert_redirected_to wallpaper_path(assigns(:wallpaper))
  end

  test "should destroy wallpaper" do
    assert_difference('Wallpaper.count', -1) do
      delete :destroy, id: @wallpaper
    end

    assert_redirected_to wallpapers_path
  end
end
