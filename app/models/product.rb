class Product < ApplicationRecord
    validates :product_name, presence: true
    validates_format_of :product_name, with: /\A[a-zA-Z0-9\s]*\z/, message: "solo puede contener letras, números y espacios"    
end
