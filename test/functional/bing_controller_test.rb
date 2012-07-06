require 'test_helper'

class BingControllerTest < ActionController::TestCase
  test "should get results" do
    get :results
    assert_response :success
  end

  

end
