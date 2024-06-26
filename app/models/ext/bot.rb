module Ext
  class Bot < Entity
    belongs_to :account__company,
               polymorphic: true,
               foreign_key: :account__holder_id,
               foreign_type: :account__holder_type

    has_many :account__audits,
             as: :auditor

    def audit! = "#{provider}Auditor".constantize.audit! self

    def token
      @token ||= Ext::Token
        .valid
        .find_by(provider: provider,
               authorizer_id: id,
               authorizer_type: self.class.name)
    end

    def token!
      @token ||= token.presence ||
        Ext::Token
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by!(
          authorizer: self,
          provider: provider,

          **{ 'refresh_token' => refresh_token }
            .merge(
              provider.constantize::BotAccessTokenClient.create(**refresh_token_params)
              .tap do |token_info|
                token_info['expires_at'] ||= Time.current + token_info['expires_in'].to_i.seconds
                token_info['scope'] = token_info['scope'].to_s
              end
            )
              .slice('access_token', 'refresh_token', 'expires_at', 'scope')
              .compact
        )
    end

    def refresh_token_params
      case provider
      when 'GitHub' then { installation_id: external_id }
      else               { refresh_token: refresh_token }
      end
    end

    def external_data!
      external_data.presence ||
        external_data_client.show(external_id).tap do |data|
          update external_data: data
        end
    end

    def external_data_client = provider.constantize::InstallationClient

    def refresh_token
      Ext::Token
        .find_by(provider: provider, authorizer_id: id,
                 authorizer_type: self.class.name)
        &.refresh_token
    end
  end
end
