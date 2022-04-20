require 'test_helper'

class BasesControllerTest < ActionDispatch::IntegrationTest
  test "should get base_index" do
    get bases_base_index_url
    assert_response :success
  end

end
