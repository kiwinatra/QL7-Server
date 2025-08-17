require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)
module Ql7BankServer class Application < Rails::Application config.load_defaults 6.1 config.api_only = true config.time_zone = 'Moscow' config.i18n.default_locale = :ru config.middleware.insert_before 0, Rack::Cors do allow do origins ENV['CLIENT_URL'] || 'http://localhost:3000' resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true end end config.autoload_paths += %W( config.middleware.use Rack::Attack config.middleware.use ActionDispatch::Cookies config.middleware.use ActionDispatch::Session::CookieStore end
end