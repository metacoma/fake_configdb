require './sample.rb'

use Rack::Session::Cookie
run Rack::Cascade.new [API, Web]
