class Environment < Grape::API
  namespace 'config/environments' do

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

    params do
      requires :env_id, type: Integer, desc: 'Environment id'
    end
    route_param :env_id do
      get do
        {env_id: params[:env_id]}
      end
      namespace 'node' do
        params do
          requires :node_id, type: Integer, desc: 'Node id'
        end
        route_param :node_id do
          get do
            { env_id: params[:env_id], node_id: params[:node_id] }
          end
          namespace 'resources' do
            # XXX grape-swagger and grape-router-helpers bug!
            # TODO match resources including "/"
            route_param :resource do
              get do
                  if params[:resource].end_with?("/values") then
                      #{ method: "GET", env_id: params[:env_id], node_id: params[:node_id]}
                      params[:resource]['/values'] = ''
                      $storage.get(params[:env_id], params[:node_id], params[:resource])
                    else
                      error!('500 /values', 500)
                  end
              end
              put do
                  { env_id: params[:env_id], node_id: params[:node_id], resource: params[:resource]}
		              begin
                      $storage.put(params[:env_id], params[:node_id], params[:resource], JSON.load(request.body.read))
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
