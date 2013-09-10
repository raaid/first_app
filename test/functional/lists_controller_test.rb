require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    login
    @list = lists(:johns_public_list)
    @altlist = lists(:johns_custom_list)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create list" do
    assert_difference('List.count') do
      post :create, list: @list.attributes
    end

    assert_response :redirect
  end

  test "should show list" do
    get :show, id: @list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @list
    assert_response :success
  end

  test "should update list" do
    put :update, id: @list, list: @list.attributes
    assert_redirected_to @list
  end

  test "should not update list" do
    put :update, id: @altlist, list: @altlist.attributes
    assert_response :success
  end

  test "should destroy list" do
    assert_difference('List.count', -1) do
      delete :destroy, id: @list
    end

    assert_redirected_to lists_path
  end

  test "trending list is initially empty" do
    assert_equal 0, List.full_trending_list.gifts.count
    assert_equal 0, List.top10_trending_gifts.count
  end

  test "start trending adds gifts to trending iff they have a upc" do
    assert_difference('List.full_trending_list.gifts.count', 0) do
      List.start_trending(Gift.new(name: "Furbie", list: @list, rating: 1, status: Gift::AVAILABLE))
    end

    assert_difference('List.full_trending_list.gifts.count', 1) do
      List.start_trending(Gift.new(name: "Furbie", list: @list, upc: "1234", rating: 1, status: Gift::AVAILABLE))
    end
  end

  test "max of 10 items in the 'top 10' list" do
    (0..20).each do |i|
      List.start_trending(Gift.new(name: "Furbie#{i}", list: @list, upc: "1234#{i}", rating: 1, status: Gift::AVAILABLE, url: "http://www.giftopia.biz/some_item#{i}"))
    end

    assert_equal 21, List.full_trending_list.gifts.count
    assert_equal 10, List.top10_trending_gifts.count
  end
end
