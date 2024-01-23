class ApiKey < ApplicationRecord
    belongs_to :bearer, polymorphic: true
    #validates :token, presence: true
end
  