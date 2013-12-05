source 'https://rubygems.org'

gem 'rails', '3.2.16'
gem 'rails-api'
gem 'pg'
gem 'whenever', :require => false
gem 'httparty'
gem "rsolr"

group :development, :test do
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :test do
  gem 'factory_girl_rails'
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'webmock'
end

# Deploy with Capistrano
gem 'capistrano', :group => :development
