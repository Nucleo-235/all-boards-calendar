source 'https://rubygems.org'

ruby ENV['CUSTOM_RUBY_VERSION'] || '2.2.4'
gem 'rails', '4.2.5'
gem 'rails-api'
gem 'rack-cors'
gem 'sprockets', '3.6.3'
gem "responders"
gem 'pg'
gem 'actionmailer'
gem 'active_model_serializers', "0.10.0.rc4"
gem 'http_accept_language'
gem 'globalize', '~> 5.0.0'
gem 'friendly_id', '~> 5.1.0'

# workers
gem 'sinatra'
gem 'redis'
gem 'redis-namespace'
gem 'sidekiq', '~> 3.2.6'

# backend libs
gem 'kaminari'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'carrierwave_backgrounder'
gem 'high_voltage', '~> 2.2.1' # gem para paginas estaticas
# gem 'easing', '~> 0.1.0' # para ter calculos de easing no back-end
gem 'mail_form'

# front-end engine
gem 'slim'
gem 'slim-rails'

# front-end libs
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '>= 3.2'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-easing-rails'
gem 'font-awesome-rails'
gem 'bourbon'
gem 'noty-rails'
# gem 'turbolinks'
gem 'bower-rails', '~> 0.10.0'
gem 'angular-rails-templates'

# view helpers/generators
gem 'simple_form'
gem 'country_select'
gem 'cocoon' #nested forms
gem 'best_in_place', '~> 3.0.1'

# users & auth
gem 'devise', '3.5.3'
gem 'devise_token_auth', '0.1.36'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-instagram'
gem 'omniauth-twitter'
gem 'omniauth-linkedin'
gem 'omniauth-google-oauth2'
gem 'omniauth-trello'
gem 'ruby-trello'

# mail, analytics & logs
gem 'madmimi'
gem 'google-analytics-rails'
gem 'rollbar'

group :development do
  gem 'annotate', '>=2.6.0'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'spring'
  gem 'xray-rails'
  gem 'rails-erd', github: 'paulwittmann/rails-erd', branch: 'mavericks'
  gem 'letter_opener'
end

group :test do
  gem 'shoulda-matchers'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :production do
  gem 'rails_12factor'
end
