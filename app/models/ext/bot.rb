module Ext
  class Bot < Entity
    belongs_to :account__company,
               polymorphic: true,
               foreign_key: :account__holder_id,
               foreign_type: :account__holder_type

    has_many :tokens,
             as: :authorizer

    has_many :account__audits,
             as: :auditor

    def audit!
      "#{provider}Auditor".constantize.audit! self
    end

    def token!
      token.presence ||
        Ext::Token.create!(
          authorizer: self,
          provider: provider,
          **provider.constantize::BotAccessTokenClient.create(
            **refresh_token_params
          ).slice('access_token', 'refresh_token', 'expires_at', 'expires_in', 'scope')
        )
    end

    def token
      tokens.valid.first
    end

    def refresh_token_params
      case provider
      when 'GitHub'           then { installation_id: external_id }
      when 'Jira', 'Heroku'   then { refresh_token: refresh_token }
      end
    end

    def refresh_token
      tokens.last.refresh_token
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
