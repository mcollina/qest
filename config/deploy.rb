set :application, "mqtt-rest"
set :repository,  "gitolite@repo.matteocollina.com:mqtt-rest"

#set :scm, :subversion
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

ip = "callisto.matteocollina.com"

role :web, ip 
role :app, ip
role :db, ip, :primary => true

set :user, "deploy"

set :use_sudo, false

set :app_port, 8000
set :mqtt_port, 8001

# support for github
ssh_options[:forward_agent] = true
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :deploy_to, "/home/deploy/apps/#{application}"

# to avoid touching the public/javascripts public/images and public/stylesheets
set :normalize_asset_timestamps, false

# Automatically put out mantainance page during updates.
# before "deploy", "deploy:web:disable"
# after "deploy", "deploy:web:enable"

namespace :deploy do
  task :start do
    run "cd #{current_path} && DISPLAY=:0 forever start app.js -p #{app_port} -m #{mqtt_port}"
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
end

after "deploy:update_code", "dependencies:install"
