require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = User.create!(email: 'test_email.com', password: 'password')
    @token = 'some_token'
    @invalid_token = 'invalid_token'
    @user.create_api_key!(token: @token) 
  end

  test "should get index" do
    get products_url, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :success
  end

# if ENV['USE_ASYNC'] == 'true'    
  # test "should enqueue job to create product" do
  #   assert_enqueued_jobs 1 do
  #     post products_url, params: { product: { product_name: 'Coca Cola' } }, headers: { 'Authorization': "Bearer #{@token}" }
  #   end
  #   assert_response :created
  # end
# else

  test "should create product" do
    assert_difference('Product.count') do
      post products_url, params: { product: { product_name: 'Coca Cola' } }, headers: { 'Authorization': "Bearer #{@token}" }
    end
    assert_not_nil Product.find_by(product_name: 'Coca Cola')
    assert_response :created
  end
  
  test "should get created product" do
    post products_url, params: { product: { product_name: 'Alfajor Jorgito' } }, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :created
    get products_url, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :success
    assert_equal 'Alfajor Jorgito', JSON.parse(response.body).first['product_name']
  end

  # end

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

end
