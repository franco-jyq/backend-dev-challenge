require "test_helper"
require 'webmock/minitest'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Configuración de WebMock para interceptar llamadas a Firebase
    signup_firebase_url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=#{Rails.application.credentials.firebase_api_key}"
    stub_request(:post, signup_firebase_url).to_return(
      body: { idToken: 'new_token' }.to_json,
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    )

    login_firebase_url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=#{Rails.application.credentials.firebase_api_key}"
    stub_request(:post, login_firebase_url).to_return(
      body: { idToken: 'new_token' }.to_json,
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    )

    @user_params = { email: 'createuser@example.com', password: 'password' }
    @no_existing_user_params = { email: 'noexistinguser@example.com', password: 'password' }
    @wrong_password_params = { email: 'logintest@example.com', password: 'wrong_password' }
    @no_api_key_user_params = { email: 'nokeyuser@example.com', password: 'password' }
    @existing_user_params = {email: 'logintest@example.com', password: 'password'}

    @existing_user = User.create!(email: 'logintest@example.com', password: 'password')
    @existing_user.create_api_key(token: 'old_token')
    @no_api_key_user = User.create!(email: 'nokeyuser@example.com', password: 'password')
    @logged_user = User.create(email:'loggeduser@example.com', password: 'password')
    @logged_user.create_api_key(token: 'some_token')

  end
  
  # Create tests

  test 'should return error when email is missing in create' do
    post users_path, params: { user: { email: '', password: 'password' } }
    assert_response :bad_request
    assert_equal 'Completa los campos de correo electrónico y contraseña', JSON.parse(@response.body)['error']
  end

  test 'should return error when password is missing in create' do
    post users_path, params: { user: { email: 'email@example.com', password: '' } }
    assert_response :bad_request
    assert_equal 'Completa los campos de correo electrónico y contraseña', JSON.parse(@response.body)['error']
  end

  test "should create user and api key" do
    assert_difference('User.count') do
      post users_path, params: { user: @user_params }
    end

    assert_response :created
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:user).api_key
    assert_equal 'new_token', assigns(:user).api_key.token
  end  

  # Login tests

  test 'should return error when email is missing in login' do
    post users_login_path, params: { user: { email: '', password: 'password' } }
    assert_response :bad_request
    assert_equal 'Completa los campos de correo electrónico y contraseña', JSON.parse(@response.body)['error']
  end

  test 'should return error when password is missing in login' do
    post users_login_path, params: { user: { email: 'email@example.com', password: '' } }
    assert_response :bad_request
    assert_equal 'Completa los campos de correo electrónico y contraseña', JSON.parse(@response.body)['error']
  end

  test "should return error when user does not exist" do
    post users_login_path, params: { user:@no_existing_user_params }
    assert_response :forbidden
    assert_equal 'Usuario no existe', JSON.parse(response.body)['error']
  end

  test "should return error with wrong password" do
    post users_login_path, params: { user:@wrong_password_params }
    assert_response :unauthorized
    assert_equal 'Contraseña incorrecta', JSON.parse(response.body)['error']
  end

  test "should return error when user does not have a token" do
    post users_login_path, params: { user:@no_api_key_user_params }
    assert_response :internal_server_error
    assert_equal 'Internal server error', JSON.parse(response.body)['error']
  end

  test "should update token and return new token when user exists and has a token" do
    assert_equal 'old_token', @existing_user.api_key.token
    post users_login_path, params: { user:@existing_user_params}
    assert_response :ok
    assert_equal 'new_token', JSON.parse(response.body)['new_token']
    assert_equal 'new_token', @existing_user.api_key.reload.token
  end


  # Logout tests

  test "should update token to nil when user logs out" do
    post users_logout_path, params: { email: @logged_user.email}
    assert_response :ok
    assert_nil @logged_user.api_key.reload.token
  end
  
end
