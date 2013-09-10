require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    login
    @comment = comments(:john_posts_first)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, comment: @comment.attributes
    end

    assert_redirected_to posts_path
  end

  test "should show comment" do
    get :show, id: @comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @comment
    assert_response :success
  end

  test "should update comment" do
    put :update, id: @comment, comment: @comment.attributes
    assert_redirected_to posts_path
  end

  test "should destroy comment" do
    assert_difference('Comment.count', -1) do
      delete :destroy, id: @comment
    end

    assert_redirected_to posts_path
  end
end
