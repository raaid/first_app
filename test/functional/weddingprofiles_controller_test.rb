require 'test_helper'

class WeddingprofilesControllerTest < ActionController::TestCase
  setup do
    @weddingprofile = weddingprofiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weddingprofiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weddingprofile" do
    assert_difference('Weddingprofile.count') do
      post :create, weddingprofile: { bio1: @weddingprofile.bio1, bio1: @weddingprofile.bio1, partner_first: @weddingprofile.partner_first, partner_last: @weddingprofile.partner_last, photo1_content_type: @weddingprofile.photo1_content_type, photo1_file_name: @weddingprofile.photo1_file_name, photo1_file_size: @weddingprofile.photo1_file_size, photo2_content_type: @weddingprofile.photo2_content_type, photo2_file_name: @weddingprofile.photo2_file_name, photo2_file_size: @weddingprofile.photo2_file_size, photo3_content_type: @weddingprofile.photo3_content_type, photo3_file_name: @weddingprofile.photo3_file_name, photo3_file_size: @weddingprofile.photo3_file_size, photo4_content_type: @weddingprofile.photo4_content_type, photo4_file_name: @weddingprofile.photo4_file_name, photo4_file_size: @weddingprofile.photo4_file_size }
    end

    assert_redirected_to weddingprofile_path(assigns(:weddingprofile))
  end

  test "should show weddingprofile" do
    get :show, id: @weddingprofile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @weddingprofile
    assert_response :success
  end

  test "should update weddingprofile" do
    put :update, id: @weddingprofile, weddingprofile: { bio1: @weddingprofile.bio1, bio1: @weddingprofile.bio1, partner_first: @weddingprofile.partner_first, partner_last: @weddingprofile.partner_last, photo1_content_type: @weddingprofile.photo1_content_type, photo1_file_name: @weddingprofile.photo1_file_name, photo1_file_size: @weddingprofile.photo1_file_size, photo2_content_type: @weddingprofile.photo2_content_type, photo2_file_name: @weddingprofile.photo2_file_name, photo2_file_size: @weddingprofile.photo2_file_size, photo3_content_type: @weddingprofile.photo3_content_type, photo3_file_name: @weddingprofile.photo3_file_name, photo3_file_size: @weddingprofile.photo3_file_size, photo4_content_type: @weddingprofile.photo4_content_type, photo4_file_name: @weddingprofile.photo4_file_name, photo4_file_size: @weddingprofile.photo4_file_size }
    assert_redirected_to weddingprofile_path(assigns(:weddingprofile))
  end

  test "should destroy weddingprofile" do
    assert_difference('Weddingprofile.count', -1) do
      delete :destroy, id: @weddingprofile
    end

    assert_redirected_to weddingprofiles_path
  end
end
