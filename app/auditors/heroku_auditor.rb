class HerokuAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    teams = Heroku::TeamsClient
      .index(@bot.token!.access_token)
      .map do |team_data|
        Ext::Resource.create_or_find_by! \
          name: team_data['name'],
          external_id: team_data['id'],
          external_data: team_data,
          external_type: 'Team',
          provider: 'Heroku',
          account__company: @bot.account__company
      end
  end
end
