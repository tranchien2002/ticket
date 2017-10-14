source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.2'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers', '~> 0.10.6'
gem 'config'

gem "bulk_insert"
gem "ransack"
gem 'faker', github: 'stympy/faker'

#7/8
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'acts-as-taggable-on'
gem 'pg_search'
gem 'paper_trail'
gem 'rails-i18n'
gem 'will_paginate'
gem 'attachinary'
gem 'rails-settings-cached'
gem 'carrierwave'
gem "rack-cors"
gem 'responders'
gem 'mini_magick'

gem "awesome_nested_set"
#===========

#4/10
gem 'whenever', :require => false
#===========

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
