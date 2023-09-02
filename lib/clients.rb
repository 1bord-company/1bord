require './lib/clients/access_token_client/base.rb'

%w[asana].each do |provider|
  provider_module = Object.const_set provider.camelize, Module.new

  data = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider}.yml")[provider]

  provider_module.const_set \
    'BotAccessTokenClient',
    (Class.new AccessTokenClient::Base do
      const_set :BASE_URL, 'https://' + data['base_url']
      const_set :TOKEN_PATH, data['token_path']
    end)
end
