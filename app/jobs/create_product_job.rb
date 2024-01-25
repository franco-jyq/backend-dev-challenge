class CreateProductJob < ApplicationJob
  queue_as :default

  def perform(product_name)
    product = Product.new(product_name: product_name)
    product.save
  end
end
