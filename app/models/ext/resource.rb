class Ext::Resource < Ext::Entity
  has_many :roles

  belongs_to :account__company,
             polymorphic: true,
             foreign_key: :account__holder_id,
             foreign_type: :account__holder_type

  has_many :account__audits,
           as: :auditee

  has_and_belongs_to_many :personas,
                          join_table: 'ext/roles'

  def manage_url
    case provider
    when 'Google' then 'https://admin.google.com/u/1/ac/users'
    when 'GitHub' then "https://github.com/orgs/#{name}/people"
    when 'Slack' then "https://#{external_data['domain']}.slack.com/admin"
    when 'Heroku' then "https://dashboard.heroku.com/teams/#{name}/access"
    end
  end
end
