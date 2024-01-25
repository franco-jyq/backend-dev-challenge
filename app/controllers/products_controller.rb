class ProductsController < ApplicationController
    include ApiKeyAuthenticatable
  
    prepend_before_action :authenticate_with_api_key!, only: %i[index create] 
    
    # TODO: hacer documentacion de la api

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
    # - En caso de éxito: JSON del producto creado y estado HTTP 201 (creado)
    # - Si falta el nombre del producto: mensaje de error y estado HTTP 400 (solicitud incorrecta)
    # - Si el nombre del producto es inválido: mensaje de error y estado HTTP 422 (entidad no procesable)
    # - Si ocurre otro error: mensaje de error y estado HTTP 500 (error interno del servidor)
    def create    
        unless params[:product][:product_name].present?
          render json: { error: 'El nombre del producto debe estar presente' }, status: :bad_request and return
        end
        product_name = params[:product][:product_name]
        @product = Product.new(product_name: product_name)
        
        if @product.save          
          render json: { success: 'Producto creado', product: product_name }, status: :created

        elsif @product.errors.details[:product_name].any? { |error| error[:error] == :invalid }
            render json: { error: 'Nombre de producto invalido, solo puede contener letras, números y espacios' }, status: :unprocessable_entity and return
        else
          render json: { error: 'No se pudo crear el producto', details: @product.errors.full_messages }, status: :internal_server_error
        end        
    end    

end

