class JiraAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    resources =
      Jira::AccessibleResourcesClient
      .index(@bot.token!.token).map do |resource|
        Ext::Resource.create!(
          name: resource['name'],
          external_id: resource['id'],
          account__company: Account::Current.company,
          external_type: 'Resource',
          external_data: resource,
          provider: 'Jira'
        )
      end

    resources.each do |resource|
      Jira::UsersClient
        .index(@bot.token!.token, resource.external_id)
        .each do |user|
          persona = Ext::Persona.create!(
            name: user['displayName'],
            external_id: user['accountId'],
            external_type: (user['accountType'] == 'app' ? 'Bot' : 'User'),
            account__holder: Account::Current.company,
            external_data: user,
            provider: 'Jira'
          )

          persona.roles.create!(
            resource: resource,
            name: 'Role',
            provider: 'Jira'
          )

          next if persona.name != '1bord Basic'

          @bot = Ext::Bot.create!(
            external_id: persona.external_id,
            external_type: 'Bot',
            provider: 'Jira',
            external_data: persona.external_data,
            account__company: Account::Current.company
          )

          Account::Audit.create! auditor: @bot, auditee: resource
        end
    end
  end
end
