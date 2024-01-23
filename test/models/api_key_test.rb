require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @api_key = ApiKey.new(bearer: @user, token: 'some_token')
  end

  test "should be valid when bearer and token are present" do
    assert @api_key.valid?
  end

  test "should not be valid when bearer is not present" do
    @api_key.bearer = nil
    assert_not @api_key.valid?
  end

  test "should be valid when token is not present" do
    @api_key.token = ''
    assert @api_key.valid?
  end

  def teardown
    @user.destroy
    @api_key.destroy
  end

end
