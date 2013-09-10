require 'test_helper'

class LikesControllerTest < ActionController::TestCase
  setup do
    login
    @like = likes(:john_likes_starbucks)
    @empty = likes(:john_likes_empty)
  end

  test "should create like" do
    assert_difference('Like.count', 1) do
      post :create, like: @like.attributes
    end
    
    assert_response :success
  end

  test "should not create like" do
    assert_no_difference('Like.count') do
      #try {
      #  post :create, like: @empty.attributes
      #}
      Like.create(@empty.attributes)
    end
  end

  test "should destroy like" do
    assert_difference('Like.count', -1) do
      delete :destroy, id: @like
    end

    #assert_redirected_to user_path(@like.user)
    assert_response :success
  end
end
