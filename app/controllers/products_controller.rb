class ProductsController < ApplicationController
    include ApiKeyAuthenticatable
  
    prepend_before_action :authenticate_with_api_key!, only: %i[index create] 
    
    api :GET, '/products', 'Lista los productos creados'
    header 'Bearer token', 'token', required: true
    returns code: 200, desc: 'Ok' do
      property :products, Array, desc: 'Array de productos' do
        property :id, Integer, desc: "Id del producto"
        property :product_name, String, desc: "Nombre del producto"
      end
    end
    def index
      @products = Product.all
      render json: @products.as_json(only: [:id, :product_name])
    end
    
    # APIPIE doc
    api :POST, '/products', 'Crea un nuevo producto'
    header 'Authorization', 'Token de autorización', required: true
    param :product, Hash, desc: 'Información del producto', required: true do
      param :product_name, String, desc: 'Nombre del producto', required: true
    end
    returns code: 201, desc: 'Created' do
      property :success, String, desc: 'Producto creado'
      property :product, String, desc: 'Nombre del producto'
    end
    error code: 400, desc: 'Solicitud incorrecta - El nombre del producto debe estar presente '
    error code: 422, desc: 'Entidad no procesable - Nombre de producto invalido, solo puede contener letras, números y espacios'
    error code: 500, desc: 'Error interno del servidor - No se pudo crear el producto'
    # APIPIE doc
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


