class Components < Grape::API

  namespace "config/components" do
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
end
