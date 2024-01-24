class ProductsController < ApplicationController
    include ApiKeyAuthenticatable
  
    # Require token authentication for index                                 
    prepend_before_action :authenticate_with_api_key!, only: %i[index create] 
    
    def index
        @products = Product.all
        render json: @products.as_json(only: [:id, :product_name])
    end
            
    # def create        
    #     CreateProductJob.perform_later(product_params.to_h)
    #     render json: { success: 'El producto se está creando' }, status: :accepted
    # end
    
    def create        
        @product = Product.new(product_params)
        if @product.save
          render json: @product, status: :created
        else
          render json: { error: 'No se pudo crear el producto', details: @product.errors.full_messages }, status: :unprocessable_entity
        end        
    end    

    private

    def product_params
      params.require(:product).permit(:product_name)
    end

end
