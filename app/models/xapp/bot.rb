class Xapp::Bot < ApplicationRecord
  belongs_to :redirect

  has_many :sync__tokens,
           class_name: 'Sync::Token',
           as: :authorizer

  def external_data!
    external_data ||
      external_data_client.show(external_id).tap do |data|
        update external_data: data
      end
  end

  def external_data_client = provider.constantize::InstallationClient

  def sync__token!
    sync__tokens.valid.first.presence ||
      Sync::Token.create!(
        authorizer: self,
        provider: provider,
        **provider.constantize::BotAccessTokenClient.create(
          installation_id: external_id
        )
      )
  end
end
