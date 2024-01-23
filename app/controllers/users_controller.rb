require 'net/http'
require 'uri'
require 'json'

class UsersController < ApplicationController
    include ApiKeyAuthenticatable    
    
    def login
                
        @user = User.new(user_params)
        existing_user = User.find_by(email: @user.email)
        
        # Usuario no existe
        unless existing_user
            render json: { error: 'El usuario no existe' }, status: :conflict and return
        end
        
        # Contraseña incorrecta
        if not existing_user&.authenticate(@user.password)
            render json: { error: 'La contraseña es incorrecta' }, status: :conflict and return
        end

        if existing_user.api_key            
            url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=#{Rails.application.credentials.firebase_api_key}"
            new_token = fetch_token(url)                                    
            existing_user.api_key.update(token: new_token)
            render json: { success: 'Token para autenticación', new_token: new_token }, status: :ok
        else
            render json: { error: 'El usuario no tiene un Token asociado' }, status: :unprocessable_entity          
        end
      
    end 
      
    def create
        @user = User.new(user_params)
        # Si el usuario ya existe retorna un error
        if User.find_by(email: @user.email)
            render json: { error: 'El usuario ya existe' }, status: :conflict and return
        end
        if @user.save                        
            url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=#{Rails.application.credentials.firebase_api_key}"
            token = fetch_token(url)        
            api_key = @user.create_api_key!(token: token)
            render json: api_key, status: :created and return
      else
        render json: { error: 'No se pudo crear el usuario', details: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def logout                
        @user = User.find_by(email: params[:email])
        if @user&.api_key                        
            @user.api_key.update(token: nil)
            @user.api_key.reload
            puts @user.api_key.token
            render json: {success: 'Usuario deslogueado exitosamente'}, status: :ok and return
        else            
            render json: { error: 'No se pudo desloguear al usuario' }, status: :unprocessable_entity
        end
    end

    private
  
    def user_params
        params.require(:user).permit(:email, :password)
    end

    def fetch_token(url)
        uri = URI(url)
        response = Net::HTTP.post_form(uri, "email": @user.email, "password": @user.password, returnSecureToken: true)
        data = JSON.parse(response.body)
        data["idToken"]
    end
  end
  