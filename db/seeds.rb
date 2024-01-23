# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
require 'net/http'
require 'uri'
require 'json'


url = "#{Rails.application.credentials.fudo_endpoint}"
uri = URI(url)

request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

data = JSON.parse(response.body)
puts "Syncing products..."

data['data'].each do |product_data|
  Product.create!(product_name: product_data['name'])
end
