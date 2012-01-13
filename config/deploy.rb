set :application, "sharpnodes"
set :repository,  "git@github.com:Indigeni/SharpNodes.git"

#set :scm, :subversion
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

ip = "rest-mqtt.matteocollina.com"

role :web, ip 
role :app, ip
role :db, ip, :primary => true

set :user, "deploy"

set :use_sudo, false

set :app_port, 8000

# support for github
ssh_options[:forward_agent] = true

set :deploy_to, "/home/deploy/apps/#{application}"

# to avoid touching the public/javascripts public/images and public/stylesheets
set :normalize_asset_timestamps, false

# Automatically put out mantainance page during updates.
# before "deploy", "deploy:web:disable"
# after "deploy", "deploy:web:enable"

namespace :deploy do
  task :start do
    run "cd #{current_path} && DISPLAY=:0 forever start app.js -p #{app_port}"
  end

  task :stop do 
    run "cd #{current_path} && forever stop app.js"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  task :migrate do
    # do nothing here!!
  end
end

namespace :dependencies do
  task :install do
    run "cd #{release_path} && npm install"
  end

  task :install_forever do
    run "npm install forever -g"
  end
end

before "deploy:cold", "dependencies:install_forever"
after "deploy:update_code", "dependencies:install"
