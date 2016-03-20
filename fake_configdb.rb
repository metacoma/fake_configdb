require 'sinatra'
require 'grape'
require 'grape/route_helpers'

class Web < Sinatra::Base
  get '/' do
    "Hello world."
  end
end

class ConfigdbBackend 
  def put(env_id,node_id,resource) 
    raise NotImplementedError.new("You must implement #{name}.")
  end
  def get(env_id,node_id,resource) 
    raise NotImplementedError.new("You must implement #{name}.")
  end
end

class MemoryBackend < ConfigdbBackend
  @storage = {} 
  def put(env_id,node_id,resource, data) 
    @storage[:env_id][:node_id][:resource] = data
  end
  def get(env_id,node_id,resource) 
    @storage[:env_id][:node_id][:resource]   
  end
end

$backend = MemoryBackend.new() 

class API < Grape::API
  prefix "/api/v1/config"

  def api_v1_anything_path
    return 1
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
                      a = $backend.get(params[:env_id], params[:node_id], params[:anything]) 
                      { method: "GET", env_id: params[:env_id], node_id: params[:node_id]} 
                    else
                       error! '/values 500'
                  end
                else
                  { method: "POST", env_id: params[:env_id], node_id: params[:node_id]} 
                  $backend.put(params[:env_id], params[:node_id], params[:anything], params[:data]) 
              end
            end
          end
        end 
      end
    end
  end
end
