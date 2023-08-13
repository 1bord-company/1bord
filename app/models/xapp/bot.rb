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
end
