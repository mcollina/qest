set :application, "qest"
set :repository,  "git@bitbucket.org:mcollina/qest.git"

set :stages, %w(development staging production)
set :default_stage, "development"

require 'capistrano/ext/multistage'

#set :scm, :subversion
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :use_sudo, true

# support for github
ssh_options[:forward_agent] = true
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :deploy_to, "/var/#{application}"

# to avoid touching the public/javascripts public/images and public/stylesheets
set :normalize_asset_timestamps, false

require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_type, :system                    # we have rvm installed by root
set :rvm_ruby_string, 'ruby-1.9.3-p194@qest'

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    # Hack to have capistrano enter the sudo password (for rvmsudo later)
    sudo "whoami"
    run "rvm rvmrc trust #{release_path}"
    run "cd #{release_path} && rvmsudo foreman export upstart /etc/init -a #{application} -u #{running_user} -l #{release_path}/log"
  end
end

after "deploy:update", "foreman:export"

namespace :deploy do
  task :start do
    run "#{sudo} start #{application}"
  end

  task :stop do 
    run "#{sudo} stop #{application}"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} start #{application} || #{sudo} restart #{application}"
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
