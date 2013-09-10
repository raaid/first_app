require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    login
    @post = posts(:johns_gift_post)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should show post" do
    get :show, id: @post
    assert_response :success
  end

  test "posts and comments show" do
    get :index
    assert_select ".post", 3
    
    # one from the user, and one from a friend
    assert_select ".comment", 2
  end

  test "joe sees john's posts" do
    login :joe_blow

    get :index
    assert_select ".post", 3
  end
end
