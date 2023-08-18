module Ext
  class Bot < Entity
    belongs_to :account__company,
               foreign_key: :account__holder_id

    has_many :tokens,
             as: :authorizer

    has_many :account__audits,
             as: :auditor

    def token!
      token.presence ||
        Ext::Token.create!(
          authorizer: self,
          provider: provider,
          **provider.constantize::BotAccessTokenClient.create(
            installation_id: external_id
          )
        )
    end

    def token
      tokens.valid.first
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
