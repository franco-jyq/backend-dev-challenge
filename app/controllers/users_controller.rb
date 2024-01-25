require 'net/http'
require 'uri'
require 'json'

class UsersController < ApplicationController
    

    before_action :check_params, only: [:login, :create, :logout]
        
        # APIPIE doc
        api :POST, '/users/login', 'Inicia sesión con un usuario existente'
        param :user, Hash, desc: "Información del usuario", required: true do
            param :email, String, desc: "Correo electrónico del usuario", required: true
            param :password, String, desc: "Contraseña del usuario", required: true
        end
        returns code: 200, desc: "Ok" do
            property :success, String, desc: "Token para autenticación"
            property :new_token, String, desc: "Token"
        end
        error code: 403, desc: "Prohibido - Usuario no existe"
        error code: 401, desc: "No autorizado - Contraseña incorrecta"
        error code: 500, desc: "Error interno del servidor"
        # APIPIE doc
        def login
            @email = params[:user][:email]
            @password = params[:user][:password]
            
            existing_user = User.find_by(email: @email)
            
            unless existing_user
                render json: { error: 'Usuario no existe' }, status: :forbidden and return
            end
            
            if not existing_user&.authenticate(@password)
                render json: { error: 'Contraseña incorrecta' }, status: :unauthorized and return
            end
            
            if existing_user.api_key            
                url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=#{Rails.application.credentials.firebase_api_key}"
                new_token = fetch_token(url)                                    
                existing_user.api_key.update(token: new_token)
                render json: { success: 'Token para autenticación', new_token: new_token }, status: :ok
            else
                render json: { error: 'Internal server error' }, status: :internal_server_error          
            end        
        end 
        
        # APIPIE doc
        api :POST, '/users', 'Crea un nuevo usuario'
        param :user, Hash, desc: "Información del usuario", required: true do
            param :email, String, desc: "Correo electrónico del usuario", required: true
            param :password, String, desc: "Contraseña del usuario", required: true
        end
        returns code: 201, desc: "Creado" do
            property :success, String, desc: "Token para autenticación"
            property :token, String, desc: "Token"
        end
        error code: 409, desc: "Conflicto - El usuario ya existe"
        error code: 500, desc: "Error interno del servidor - No se pudo crear el usuario"
        # APIPIE doc
        def create
            @email = params[:user][:email]
            @password = params[:user][:password]
            
            if User.find_by(email: @email)
                render json: { error: 'El usuario ya existe' }, status: :conflict and return
            end
            @user = User.new(email: @email, password: @password)
            
            if @user.save                        
                url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=#{Rails.application.credentials.firebase_api_key}"
                token = fetch_token(url)        
                api_key = @user.create_api_key!(token: token)
                render json: { success: 'Token para autenticación', token: token }, status: :created
            else
                render json: { error: 'No se pudo crear el usuario', details: @user.errors.full_messages }, status: :internal_server_error
            end
        end
        
        
        # APIPIE doc
        api :POST, '/users/logout', 'Cierra sesion de un usuario'
        param :user, Hash, desc: 'Informacion del usuario' do
          param :email, String, desc: 'Correo electronico del usuario', required: true
          param :password, String, desc: 'Contraseña del usuario', required: true
        end
        returns code: 200, desc: 'Deslogueo exitoso' do
          property :success, String, desc: 'Usuario deslogueado exitosamente'
        end        
        error code: 401, desc: "No autorizado - Contraseña incorrecta"        
        error code: 403, desc: "Prohibido - Usuario no existe"
        error code: 500, desc: "Error interno del servidor"
        # APIPIE doc
        def logout                
            @email = params[:user][:email]
            @password = params[:user][:password]
            
            @user = User.find_by(email: @email)
            unless @user
                render json: { error: 'Usuario no existe' }, status: :forbidden and return
            end
            
            if not @user&.authenticate(@password)
                render json: { error: 'Contraseña incorrecta' }, status: :unauthorized and return
            end
            
            if @user&.api_key                        
                @user.api_key.update(token: nil)
                render json: {success: 'Usuario deslogueado exitosamente'}, status: :ok and return
            else
                render json: { error: 'No se pudo desloguear al usuario' }, status: :internal_server_error
            end
        end
        
        private
        
        # Obtiene un token de Firebase
        def fetch_token(url)
            uri = URI(url)
            response = Net::HTTP.post_form(uri, "email": @email, "password": @password, returnSecureToken: true)
            data = JSON.parse(response.body)
            if data["idToken"].nil?
                render json: { error: 'Error autenticando' }, status: :internal_server_error and return
            end
            data["idToken"]
        end
        
        # Verifica que los parámetros requeridos estén presentes
        def check_params
            unless params[:user][:email].present? && params[:user][:password].present?
                render json: { error: 'Completa los campos de correo electrónico y contraseña' }, status: :bad_request and return
            end
        end 

    end
    