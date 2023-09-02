require './lib/clients/access_token_client/base.rb'
require './lib/clients/resource_client/base.rb'

%w[asana].each do |provider|
  provider_module = Object.const_set provider.camelize, Module.new

  data = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider}.yml")[provider]

  provider_module.const_set \
    'BotAccessTokenClient',
    (Class.new AccessTokenClient::Base do
      const_set :BASE_URL, 'https://' + data['base_url']
      const_set :TOKEN_PATH, data['token_path']
    end)

  provider_resource_client = provider_module.const_set \
    'ResourceClient',
    (Class.new ResourceClient::Base do
      const_set :BASE_URL, "https://#{data['resources_base_url']}"
    end)

  data['resources'].each do |name, options|
    provider_module.const_set \
      "#{name.camelize}Client",
      (Class.new provider_resource_client do
        if options['actions'].include? 'show'
          key = "#{name.singularize}_id"
          def self.show(token, resource_id) = new(token).show(resource_id)
          def show(resource_id) = get("#{resource_name}/#{resource_id}")

          def resource_name = self.class.name.demodulize.underscore.downcase.gsub(/_client/, '')
        end
      end)
  end
end
