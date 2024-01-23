require "test_helper"

class UserTest < ActiveSupport::TestCase
  
  def setup
    @valid_user = User.new(email: 'test@example.com', password: 'password')
    @no_password_user = User.new(email: 'test2@example.com', password: '')
    @no_email_user = User.new(email: '', password: 'password')
  end

  test "should be valid" do
    assert @valid_user.valid?
  end

  test "email should be present" do
    assert_not @no_email_user.valid?
  end

  test "password should be present" do    
    assert_not @no_password_user.valid?
  end

  def teardown
    @valid_user.destroy
  end
  
end


