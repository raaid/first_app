require 'test_helper'

class NotificationsHelperTest < ActionView::TestCase
  test "notification messages" do
    assert_equal "Jane Doe wants to add you as a contact.", get_notification_text(Notification.new({user: users(:john_doe), sender: users(:jane_doe), category: Notification::NEW_CONTACT_REQUEST}))
    assert_equal "Jane Doe invited you to group buy the gift <a href=\"/gifts/1\">String</a>.", get_notification_text(Notification.new({user: users(:john_doe), sender: users(:jane_doe), category: Notification::NEW_GROUPBUY_INVITATION, gift: gifts(:one)}))
    assert_equal "Jane Doe suggested <a href=\"/gifts/1\">String</a>.", get_notification_text(Notification.new({user: users(:john_doe), sender: users(:jane_doe), category: Notification::NEW_SUGGESTION, gift: gifts(:one)}))
    assert_equal "Jane Doe gave a gift of kindness.", get_notification_text(Notification.new({user: users(:john_doe), sender: users(:jane_doe), category: Notification::NEW_KINDNESS_GIVEN}))
    assert_equal "The category of this notification is Flubber. I don't know what that means.", get_notification_text(Notification.new({user: users(:john_doe), sender: users(:jane_doe), category: "Flubber"}))
  end
end
