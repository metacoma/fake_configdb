class Environments < Grape::API
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
end
