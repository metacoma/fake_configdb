require 'json'

class ConfigdbStorage
  def initialize()
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def env_exists?(env_id)
    raise NotImplementedError.new("You must implement #{name}.")
  end

  def env(env_id)
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

  def env_exists?(env_id)
    return @storage.has_key?(env_id)
  end

  def env(env_id)
    raise ArgumentError unless env_exists?(env_id)
    @storage[env_id][:components]
  end

  def addEnv(env_id, components)
    raise ArgumentError if not env_id or env_id <= 0
    raise ArgumentError if not components.size

    unless env_exists?(env_id) then
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
