# RottenPotatoes demo app: getting started

This app is associated with the free [online
course](http://www.saas-class.org) and (non-free)
[ebook](http://www.saasbook.info) Engineering Software as a Service.

To start working on the Rails Intro homework, please follow [the instructions](instructions/README.md).

## Running the App

rbenv install 2.6.6

rbenv local 2.6.6

gem install bundler

bundle install

## Database creation

rake db:migrate

rake db:seed

## Run Server

rails server

`rails s -p 5000` for observability, since that's what I've set it to in my prometheus.yml

# Prometheus
`prometheus --config.file=/etc/prometheus/prometheus.yml`

`curl localhost:9090` double check prometheus is running properly

./prometheus --web.listen-address="0.0.0.0:9090" 

# Sources Consulted
https://grafana.com/docs/grafana/latest/setup-grafana/installation/mac/
https://github.com/prometheus/client_ruby
