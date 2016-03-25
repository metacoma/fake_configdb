require 'sinatra'
require 'grape'
require 'grape/route_helpers'
require 'grape-swagger'
require_relative './storage.rb'
require_relative './api/components.rb'
require_relative './api/environments.rb'

class AlreadyExists < StandardError; end
class ResourceNotFound < StandardError; end

class Web < Sinatra::Base
  get '/' do
    "index"
  end
end


$storage = MemoryStorage.new()

class API < Grape::API
  prefix "/api/v1"

  mount Components
  mount Environments

  add_swagger_documentation :hide_documentation_path => true,
                            :api_version => 'v1',
                            :host => 'lit-plateau-85383.herokuapp.com',
                            :info => {
                              title: "fake ConfigDB",
                              description: "fake"
                            }

end
