require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = User.create!(email: 'test_email.com', password: 'password')
    @token = 'some_token'
    @invalid_token = 'invalid_token'
    @user.create_api_key!(token: @token) 
  end


  test "should not create product without product name" do
    assert_no_difference('Product.count') do
      post products_url, params: { product: { product_name: '' } }, headers: { 'Authorization': "Bearer #{@token}" }
      assert_response :bad_request 
    end
  end

  test "should create product" do
    post products_url, params: { product: { product_name: 'Coca Cola' } }, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :accepted
  end
  
  test "should not get products without token" do
    get products_url
    assert_response :unauthorized
  end

  
  test "should not get products with invalid token" do
    get products_url headers: { 'Authorization': "Bearer #{@invalid_token}" }
    assert_response :unauthorized
  end
  
  
  test "should not create product without token" do
    assert_no_difference('Product.count') do
      post products_url, params: { product: { product_name: 'Queso Mar del Plata' } }
    end
    assert_response :unauthorized
  end


  test "should not create product with invalid token" do
    post products_url, params: { product: { product_name: 'Don Satur' } }, headers: { 'Authorization': "Bearer #{@invalid_token}" }
    assert Product.find_by(product_name: 'Don Satur').nil?
    assert_response :unauthorized
  end

  
  test "should get index" do
    get products_url, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :success
  end

end
