class User < ApplicationRecord
    has_one :api_key, as: :bearer 

    has_secure_password
    validates :email, presence: true    
end
  