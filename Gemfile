source 'https://rubygems.org'
ruby '1.9.3' 

gem 'rails', '3.2.17'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem "oj", "~> 1.2.12"

gem 'sanitize-rails'																			# Removes HTML
gem 'kaminari'																						# Pagination gem 
#gem 'sqlite3'
gem 'pg'
#gem 'activerecord-import', ">= 0.2.0"
#gem 'tf_idf'

group :development, :test do
  
  gem 'rspec-rails'																				# Test framework
  gem 'factory_girl_rails'																# Factory fixtures
end

group :test do
  gem 'faker'																							# fakes emails.etc
  gem 'capybara'																					# simulate users
  gem 'guard-rspec'																				# continuous testing
  gem 'launchy'																						# browser launcher
end



# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  
  gem 'execjs'
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'






# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
