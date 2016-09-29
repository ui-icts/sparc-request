set :rvm_ruby_string, "ruby-2.1.5"
set :rvm_type, :user

set :deploy_root, "/var/www/html/sparc"
set :deploy_to, "#{deploy_root}/#{application}"
set :rails_env, "production"
set :branch, "production"

host = fetch(:host, 'localhost')
role :web, host
role :app, host, :primary => true
role :db, host, :primary => true

require 'rvm/capistrano'
