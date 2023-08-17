module Core
  class Bot < Entity
    belongs_to :account__company,
               foreign_key: :account__holder_id

    has_many :sync__tokens,
             class_name: 'Sync::Token',
             as: :authorizer

    def sync__token!
      sync__token.presence ||
        Sync::Token.create!(
          authorizer: self,
          provider: provider,
          **provider.constantize::BotAccessTokenClient.create(
            installation_id: external_id
          )
        )
    end

    def sync__token
      sync__tokens.valid.first
    end

    def external_data!
      external_data.presence ||
        external_data_client.show(external_id).tap do |data|
          update external_data: data
        end
    end

    def external_data_client = provider.constantize::InstallationClient
  end
end
