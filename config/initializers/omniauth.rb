OmniAuth.config.logger = Rails.logger

google = Rails.application.credentials.google

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, google&.dig(:client_id), google&.dig(:client_secret)
end
