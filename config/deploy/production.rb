
ip = "metis.matteocollina.com"

role :web, ip 
role :app, ip
role :db, ip, :primary => true

set :app_port, 9001
set :mqtt_port, 8883

set :user, "matteo"
set :running_user, "qest"

set :branch, "himalia"
