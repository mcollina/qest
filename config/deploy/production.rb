
ip = "callisto.matteocollina.com"

role :web, ip 
role :app, ip
role :db, ip, :primary => true

set :app_port, 8000
set :mqtt_port, 8001

set :user, "deploy"

set :branch, "master"
