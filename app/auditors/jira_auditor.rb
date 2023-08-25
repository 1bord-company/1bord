class JiraAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    resources =
      Jira::AccessibleResourcesClient
      .index(@bot.token!.access_token).map do |resource|
        Ext::Resource
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            name: resource['name'],
            external_id: resource['id'],
            account__company: Account::Current.company,
            external_type: 'Resource',
            external_data: resource,
            provider: 'Jira'
      end

    resources.each do |resource|
      Jira::UsersClient
        .index(@bot.token!.access_token, resource.external_id)
        .each do |user|
          if user['displayName'] == '1bord Basic'
            @bot = Ext::Bot
              .extending(ActiveRecord::CreateOrFindAndUpdateBy)
              .create_or_find_and_update_by! \
                name: user['displayName'],
                external_id: user['accountId'],
                external_type: 'Bot',
                provider: 'Jira',
                external_data: user,
                account__company: Account::Current.company

            Account::Audit.create! auditor: @bot, auditee: resource
          else
            persona = Ext::Persona
              .extending(ActiveRecord::CreateOrFindAndUpdateBy)
              .create_or_find_and_update_by! \
                name: user['displayName'],
                external_id: user['accountId'],
                external_type: (user['accountType'] == 'app' ? 'Bot' : 'User'),
                account__holder: Account::Current.company,
                external_data: user,
                provider: 'Jira'

            persona.roles
              .extending(ActiveRecord::CreateOrFindAndUpdateBy)
              .create_or_find_and_update_by! \
                resource: resource,
                name: 'Role',
                provider: 'Jira'
          end
        end
    end
  end
end
