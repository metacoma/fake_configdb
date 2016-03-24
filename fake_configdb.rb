require 'sinatra'
require 'swagger-exposer'
require 'grape'
require 'grape/route_helpers'

class AlreadyExists < StandardError; end
class ResourceNotFound < StandardError; end

class Web < Sinatra::Base
  get '/' do
    "index"
  end
end

class ConfigdbStorage
  def initialize()
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def addEnv(env_id, components)
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def addComponent(name, resources)
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def listComponent(name, resources)
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def put(env_id,node_id,resource, data)
    raise NotImplementedError.new("You must implement #{name}.")
  end
  def get(env_id,node_id,resource)
    raise NotImplementedError.new("You must implement #{name}.")
  end

end

class MemoryStorage < ConfigdbStorage

  def initialize()
    @storage = {}
    @components = []
    @env = {}
  end

  def addEnv(env_id, components)
    raise ArgumentError if not env_id or env_id <= 0
    raise ArgumentError if not components.size

    if not @storage.has_key?(env_id) then
        @storage[env_id] = {}
        @storage[env_id]['nodes'] = {}
        @storage[env_id][:components] = {}

        components.each { |i|
          @components[i]['resource_definitions'].keys.each { |k|
            @storage[env_id][:components][k] = {}
          }
        }

      else
        raise AlreadyExists
    end
  end
  def put(env_id,node_id,resource, data)
    raise ArgumentError if not @storage.has_key?(env_id)
    raise ResourceNotFound if not @storage[env_id][:components].has_key?(resource)

    if not @storage[env_id]['nodes'].has_key?(node_id) then
      @storage[env_id]['nodes'][node_id] = {}
    end

    @storage[env_id]['nodes'][node_id][resource] = data
  end
  def get(env_id,node_id,resource)
    raise ArgumentError if not @storage.has_key?(env_id)
    @storage[env_id]['nodes'][node_id][resource]
  end

  def addComponent(name, resources)
    raise ArgumentError if not name or not name.size or not resources.size

    if @components.select{|c| c.has_key?(name) }.size > 0
      raise AlreadyExists
    end

    @components.push({
      "id"                   => @components.size,
      "name"                 => name,
      "resource_definitions" => resources
    })

    JSON.dump(@components.last)
  end

  def listComponents()
    JSON.dump(@components)
  end


end

$storage = MemoryStorage.new()

class API < Grape::API
  prefix "/api/v1/config"

  resource :components do
    post do
      data = JSON.load(request.body.read)
      begin
        component = $storage.addComponent(data['name'], data['resource_definitions'])
        rescue AlreadyExists
          error!('500 Already exists', 500)
        rescue ArgumentError
          error!('500 Argument error', 500)
        else
          status 201
          component
      end
    end
    get do
      $storage.listComponents()
    end
  end

  resource :environments do
    post do
      begin
        env_data = JSON.load request.body.read
        $storage.addEnv(env_data['id'], env_data['components'])
        rescue AlreadyExists
          error!('500 Already exists', 500)
        rescue ArgumentError
          error!('500 Invalid arguments', 500)
        else
        JSON.dump({ 'id' => env_data['id'] })
      end
    end
  end

  resource :environment do
    params do
      requires :env_id, type: Integer, desc: 'Environment id'
    end
    route_param :env_id do
      get do
        {env_id: params[:env_id]}
      end
      resource :node do
        params do
          requires :node_id, type: Integer, desc: 'Node id'
        end
        route_param :node_id do
          get do
            { env_id: params[:env_id], node_id: params[:node_id] }
          end
          resource :resource do
            route :any, '*anything' do
              if request.get? then
                  if params[:anything].end_with?("/values") then
                      #{ method: "GET", env_id: params[:env_id], node_id: params[:node_id]}
                      params[:anything]['/values'] = ''
                      $storage.get(params[:env_id], params[:node_id], params[:anything])
                    else
                      error!('500 /values', 500)
                  end
                else
                  { env_id: params[:env_id], node_id: params[:node_id], resource: params[:anything]}
		              begin
                      $storage.put(params[:env_id], params[:node_id], params[:anything], JSON.load(request.body.read))
		                  rescue ArgumentError, ResourceNotFound
                        error!('404', 404)
		              end
              end
            end
          end
        end
      end
    end
  end
end
