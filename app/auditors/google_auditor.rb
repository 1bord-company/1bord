class GoogleAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    data = Google::UsersClient.index(@bot.token!.access_token)['users']

    domains_users = data.group_by { _1['primaryEmail'].split('@').last }

    domains_users.each do |domain_name, users_data|
      domain = Ext::Resource.create_or_find_by! \
        name: domain_name,
        external_type: 'Domain',
        provider: 'Google',
        account__company: @bot.account__company

      users_data.each do |user_data|
        persona = Ext::Persona.create_or_find_by! \
          name: user_data['name']['fullName'],
          external_id: user_data['id'],
          external_type: 'User',
          external_data: user_data,
          provider: 'Google',
          account__holder: @bot.account__company

        Ext::Role.create_or_find_by! \
          persona: persona,
          resource: domain,
          provider: 'Google',
          name: user_data['isAdmin'] ? 'admin' : 'member'
      end

      Account::Audit.create! \
        auditee: domain,
        auditor: @bot
    end
  end
end
