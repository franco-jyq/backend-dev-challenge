require "test_helper"

class ProductTest < ActiveSupport::TestCase
  
  def setup
    @valid_product = Product.new(product_name: 'Coca Cola')
    @no_product_name = Product.new(product_name: '')    
  end

  test "should be valid" do
    assert @valid_product.valid?
   end

  test "product name should be present" do
    @valid_product.product_name = "     "
    assert_not @valid_product.valid?
  end

  test "product name should not have special characters" do
    @valid_product.product_name = "Coca$%@``Cola"
    assert_not @valid_product.valid?
  end

  test "product should be present" do
    assert_not @no_product_name.valid?
  end

  def teardown
    @valid_product.destroy
  end

end

