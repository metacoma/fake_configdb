class Environments < Grape::API
  namespace 'config/environments' do

    params do
      requires :env_id, type: Integer, desc: 'Environment id'
    end
    route_param :env_id do
      get do
        begin
            $storage.env(params[:env_id])
          rescue ArgumentError
            error!('404', 404)
        end
      end

      post do
        begin
            env_data = JSON.load request.body.read
            $storage.addEnv(params[:env_id], env_data['components'])
          rescue AlreadyExists
            error!('500 Already exists', 500)
          rescue ArgumentError
            error!('500 Invalid arguments', 500)
          else
            JSON.dump $storage.env(env_data['id'])
        end
      end


      namespace 'nodes' do
        params do
          requires :node_id, type: String, desc: 'Node id'
        end
        route_param :node_id do
          get do
            { env_id: params[:env_id], node_id: params[:node_id] }
          end
          resource :resources do
            # XXX grape-swagger and grape-router-helpers bug!
            desc 'Hide this endpoint', hidden: true
            route :any, '*anything' do
              # XXX ugly hack
              if params[:node_id].match(/[^0-9]/)
                node_id = params[:node_id].gsub(/[^0-9]/, "")
                error!("/api/v1/config/environments/#{params[:env_id]}/nodes/#{node_id}/resources/#{params[:anything]}", 308)
              end
              if request.get? then
                  if params[:anything].end_with?("/values") then
                      params[:anything]['/values'] = ''
                      begin
                          data = $storage.get(params[:env_id], params[:node_id], params[:anything])
                          if data
                              return JSON.dump $storage.get(params[:env_id], params[:node_id], params[:anything])
                            else
                              error!('404 /values', 404)

                          end
                      rescue ArgumentError
                          error!('404 /values', 404)
                      end
                    else
                      error!('500 /values', 500)
                  end
              end
              if request.put? then
                  params[:anything]['/values'] = ''
                  begin
                      data = JSON.load(request.body.read)
                      $storage.put(params[:env_id], params[:node_id], params[:anything], data)
                      rescue ArgumentError, ResourceNotFound
                        error!('404', 404)
                  end
                  { env_id: params[:env_id], node_id: params[:node_id], resource: params[:anything]}
              end
            end
          end
        end
      end
    end
  end
end
