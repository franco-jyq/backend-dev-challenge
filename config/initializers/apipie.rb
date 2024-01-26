Apipie.configure do |config|
  config.app_name                = "Products"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  config.app_info["1.0"] = "Backend Dev Challenge - Products API"
  config.validate = false

  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
