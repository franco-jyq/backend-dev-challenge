require 'net/http'
require 'uri'
require 'json'

class UsersController < ApplicationController
    
    
    before_action :check_params, only: [:login, :create]
    
    # POST /login
    # Inicia sesión con un usuario existente
    # Parámetros requeridos: 
    # - email: El correo electrónico del usuario (string)
    # - password: La contraseña del usuario (string)
    # Devuelve: 
    # - En caso de éxito: JSON con el nuevo token de autenticación y estado HTTP 200 (OK)
    # - Si el usuario no existe: mensaje de error y estado HTTP 403 (Prohibido)
    # - Si la contraseña es incorrecta: mensaje de error y estado HTTP 401 (No autorizado)
    # - Si ocurre otro error: mensaje de error y estado HTTP 500 (Error interno del servidor)
    def login
        check_params
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
    
    # POST /users
    # Crea un nuevo usuario
    # Parámetros requeridos: 
    # - email: El correo electrónico del usuario (string)
    # - password: La contraseña del usuario (string)
    # Devuelve: 
    # - En caso de éxito: JSON con la clave API del usuario y estado HTTP 201 (Creado)
    # - Si el usuario ya existe: mensaje de error y estado HTTP 409 (Conflicto)
    # - Si ocurre otro error: mensaje de error y estado HTTP 500 (Error interno del servidor)
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
            render json: api_key, status: :created and return
        else
            render json: { error: 'No se pudo crear el usuario', details: @user.errors.full_messages }, status: :internal_server_error
      end
    end
    
    # DELETE /logout
    # Cierra la sesión de un usuario
    # Parámetros requeridos: 
    # - email: El correo electrónico del usuario (string)
    # Devuelve: 
    # - En caso de éxito: mensaje de éxito y estado HTTP 200 (OK)
    # - Si ocurre un error: mensaje de error y estado HTTP 500 (Error interno del servidor)
    def logout                
        @user = User.find_by(email: params[:email])
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
  