# Add RVM's lib directory to the load path.
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require "bundler/capistrano"

environment = ENV["env"]
raise "please set env=development OR env=production" unless environment

dev_server  = "198.101.154.119"
prod_server = "198.101.207.23"
def determine_branch
  git_branch = $1 if `git branch` =~ /\* (\S+)\s/m
  if git_branch =~ /no/
    "master"
  else
    git_branch
  end
end

if environment == "production"
  puts `****** DEPLOYING TO PRODUCTION ******`
  set :application    , "jurnil"
  set :repository     , "git@github.com:redsquarelabs/Jurnil-beta.git"
  set :scm            , :git
  set :branch         , determine_branch
  set :scm_username   , "redsquarelabs"
  set :scm_passphrase , "2012jurnil"
  set :use_sudo       , false
  set :deploy_to      , "/rails_apps/#{application}"
  set :deploy_via     , :remote_cache
  set :user           , "jurnil"
  set :password       , "Secured333Jurnil"
  role :web           , prod_server                   # Your HTTP server, Apache/etc
  role :app           , prod_server                   # This may be the same as your `Web` server
  role :db            , prod_server, :primary => true # This is where Rails migrations will run
else
  #require "rvm/capistrano"
  #set :rvm_ruby_string, '1.9.2'
  #set :rvm_type, :user  # Don't use system-wide RVM
  puts `****** DEPLOYING TO DEVELOPMENT/STAGING ******`
  set :application    , "atlmetal"
  set :repository     , "git@github.com:atljeremy/atlmetal.git"
  set :scm            , :git
  set :branch         , determine_branch
  set :scm_username   , "atljeremy"
  set :scm_passphrase , "Lily123"
  set :use_sudo       , false
  set :deploy_to      , "/rails_apps/#{application}"
  set :deploy_via     , :remote_cache
  set :user           , "atlmetal"
  set :password       , "Jeremy1980"
  role :web           , dev_server                   # Your HTTP server, Apache/etc
  role :app           , dev_server                   # This may be the same as your `Web` server
  role :db            , dev_server, :primary => true # This is where Rails migrations will run
end

ssh_options[:forward_agent] = true

set :keep_releases, 5
after "deploy:update", "deploy:cleanup"
after "deploy", "deploy:migrate"

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
