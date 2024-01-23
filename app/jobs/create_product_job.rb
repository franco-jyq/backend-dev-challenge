class CreateProductJob < ApplicationJob
  queue_as :default

  def perform(product_params)
    puts "Params: #{product_params}"
    product = Product.new(product_params)
    product.save
  end
end
