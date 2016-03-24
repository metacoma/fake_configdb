class Environment < Grape::API
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
