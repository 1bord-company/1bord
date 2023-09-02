require './lib/clients/access_token_client/base'
Dir[__FILE__.gsub(/.rb$/, '') + '/**/resource_client/*.rb'].each { require _1 }

%w[asana git_hub].each do |provider|
  provider_module =
    if Object.const_defined? provider.camelize
      Object.const_get provider.camelize
    else
      Object.const_set provider.camelize, Module.new
    end

  data = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider}.yml")[provider]

  if data.key?('base_url') && data.key?('token_path')
    if provider_module.const_defined? "#{provider.camelize}::BotAccessTokenClient"
      provider_module.const_get "#{provider.camelize}::BotAccessTokenClient"
    else
      provider_module.const_set \
        'BotAccessTokenClient',
        (Class.new AccessTokenClient::Base do
          const_set :BASE_URL, 'https://' + data['base_url']
          const_set :TOKEN_PATH, data['token_path']
        end)
    end
  end

  provider_resource_client =
    if provider_module.const_defined? "#{provider.camelize}::ResourceClient"
      provider_module.const_get "#{provider.camelize}::ResourceClient"
    else
      provider_module.const_set \
      'ResourceClient',
      (Class.new ResourceClient::Base do
        const_set :BASE_URL, "https://#{data['resources_base_url']}"
      end)
    end

  data['resources']&.each do |name, options|
    if provider_module.const_defined? "#{provider.camelize}::#{name.camelize}Client"
      provider_module.const_get "#{provider.camelize}::#{name.camelize}Client"
    else
      provider_module.const_set \
        "#{name.camelize}Client",
        (Class.new provider_resource_client do
          if options['actions'].include? 'show'
            def self.show(token, resource_id) = new(token).show(resource_id)
            def show(resource_id) = get("#{resource_name}/#{resource_id}")

          end

          if options['actions'].include? 'index'
            def self.index(token) = new(token).index
            def index = get(resource_name)
          end
        end)
      end
    end
end

Dir[__FILE__.gsub(/.rb$/, '') + '/**/resource_client.rb'].each { require _1 }
Dir[__FILE__.gsub(/.rb$/, '') + '/**/*.rb'].each { require _1 }
