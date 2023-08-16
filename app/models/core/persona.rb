class Core::Persona < Core::Entity
  has_many :roles

  has_and_belongs_to_many :resources,
                           join_table: 'core/roles'

  def avatar_url
    case provider
    when 'GitHub' then external_data['avatar_url']
    when 'Slack' then external_data.dig('profile', 'image_24')
    when 'Jira' then external_data.dig('avatarUrls', '24x24')
    end
  end
end
