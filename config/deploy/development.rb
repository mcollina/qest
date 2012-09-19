ip = "127.0.0.1"

role :web, ip 
role :app, ip
role :db, ip, :primary => true

set :app_port, 8002
set :mqtt_port, 8883

set :user, "vagrant"
set :running_user, "qest"

ssh_options[:port] = 2222

set :branch, "himalia"
