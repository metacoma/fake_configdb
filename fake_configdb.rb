require 'sinatra'
require 'grape'
require 'grape/route_helpers'

class Web < Sinatra::Base
  get '/' do
    "index"
  end
end

class ConfigdbStorage
  def initialize()
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def addEnv(env_id)
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
  end
  
  def addEnv(env_id) 
    if not @storage.has_key?(env_id) then
        @storage[env_id] = {}
        puts @storage
      else
        raise ArgumentError
    end 
  end
  def put(env_id,node_id,resource, data) 
    raise ArgumentError if not @storage.has_key?(env_id)
      
    if not @storage[env_id].has_key?(node_id) then
      @storage[env_id][node_id] = {} 
    end

    @storage[env_id][node_id][resource] = data
  end
  def get(env_id,node_id,resource) 
    raise ArgumentError if not @storage.has_key?(env_id)
    @storage[env_id][node_id][resource]
  end
end

$storage = MemoryStorage.new() 

class API < Grape::API
  prefix "/api/v1/config"

  resource :environment do
    params do
      requires :env_id, type: Integer, desc: 'Environment id'
    end
    route_param :env_id do
      get do
        {env_id: params[:env_id]}
      end
      post do
        begin
          $storage.addEnv(params[:env_id]) 
          status 201
          {env_id: params[:env_id]}
        rescue ArgumentError
          error!('500 Already exists', 500)
        end
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
                  $storage.put(params[:env_id], params[:node_id], params[:anything], request.body.read) 
              end
            end
          end
        end 
      end
    end
  end
end
