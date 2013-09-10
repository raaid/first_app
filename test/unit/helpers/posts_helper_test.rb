require 'test_helper'

class PostsHelperTest < ActionView::TestCase
  test "post messages" do
    assert_equal "John Doe added <a href=\"/gifts/1\">String</a> to their gift list!", get_post_text(posts(:johns_gift_post))
    assert_equal "John Doe is now connected with Joe Blow.", get_post_text(posts(:johns_association_post))
    assert_equal "The category of this post is Flubber. I don't know what that means.", get_post_text(posts(:johns_invalid_category_post))
    assert_equal "John Doe gave a gift of kindness to Joe Blow.", get_post_text(Post.new({user: users(:john_doe), contact: users(:joe_blow), category: Post::KINDNESS_GIVEN}))
    assert_equal "John Doe suggested <a href=\"/gifts/1\">String</a> to Joe Blow.", get_post_text(Post.new({user: users(:john_doe), contact: users(:joe_blow), category: Post::SUGGESTION_MADE, gift: gifts(:one)}))
  end
end
