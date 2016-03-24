require 'sinatra'
require 'grape'
require 'grape/route_helpers'
require 'grape-swagger'
require_relative './storage.rb'
require_relative './api/components.rb'
require_relative './api/environments.rb'
require_relative './api/environment.rb'

class AlreadyExists < StandardError; end
class ResourceNotFound < StandardError; end

class Web < Sinatra::Base
  get '/' do
    "index"
  end
end


$storage = MemoryStorage.new()

class API < Grape::API
  prefix "/api/v1/config"

  mount Components
  mount Environments
  mount Environment

    add_swagger_documentation :hide_documentation_path => false,
                            :api_version => 'v1',
                            :info => {
                              title: "fake ConfigDB",
                              description: "fake"
                            }

end
