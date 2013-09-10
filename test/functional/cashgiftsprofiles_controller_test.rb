require 'test_helper'

class CashgiftsprofilesControllerTest < ActionController::TestCase
  setup do
    @cashgiftsprofile = cashgiftsprofiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cashgiftsprofiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cashgiftsprofile" do
    assert_difference('Cashgiftsprofile.count') do
      post :create, cashgiftsprofile: { message: @cashgiftsprofile.message, photo_content_type: @cashgiftsprofile.photo_content_type, photo_file_name: @cashgiftsprofile.photo_file_name, photo_file_size: @cashgiftsprofile.photo_file_size, user_id: @cashgiftsprofile.user_id }
    end

    assert_redirected_to cashgiftsprofile_path(assigns(:cashgiftsprofile))
  end

  test "should show cashgiftsprofile" do
    get :show, id: @cashgiftsprofile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cashgiftsprofile
    assert_response :success
  end

  test "should update cashgiftsprofile" do
    put :update, id: @cashgiftsprofile, cashgiftsprofile: { message: @cashgiftsprofile.message, photo_content_type: @cashgiftsprofile.photo_content_type, photo_file_name: @cashgiftsprofile.photo_file_name, photo_file_size: @cashgiftsprofile.photo_file_size, user_id: @cashgiftsprofile.user_id }
    assert_redirected_to cashgiftsprofile_path(assigns(:cashgiftsprofile))
  end

  test "should destroy cashgiftsprofile" do
    assert_difference('Cashgiftsprofile.count', -1) do
      delete :destroy, id: @cashgiftsprofile
    end

    assert_redirected_to cashgiftsprofiles_path
  end
end
