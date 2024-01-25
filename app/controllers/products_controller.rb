class ProductsController < ApplicationController
    include ApiKeyAuthenticatable
  
    prepend_before_action :authenticate_with_api_key!, only: %i[index create] 
    
    # GET /products
    # Devuelve una lista de todos los productos
    def index
        @products = Product.all
        render json: @products.as_json(only: [:id, :product_name])
    end

    # POST /products
    # Crea un nuevo producto
    # Parámetros requeridos: 
    # - product_name: El nombre del producto (string)
    # Devuelve: 
    # - En caso de éxito: JSON del producto creado y estado HTTP 200 (ok)
    # - Si falta el nombre del producto: mensaje de error y estado HTTP 400 (solicitud incorrecta)
    def create        
      unless params[:product][:product_name].present?
        render json: { error: 'El nombre del producto debe estar presente' }, status: :bad_request and return
      end
      CreateProductJob.perform_later(params[:product][:product_name])
      render json: { success: 'El producto se está creando' }, status: :accepted
    end

end

