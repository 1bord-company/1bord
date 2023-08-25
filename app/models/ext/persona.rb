require 'digest/md5'

class Ext::Persona < Ext::Entity
  has_many :roles

  belongs_to :account__holder,
             polymorphic: true

  has_and_belongs_to_many :resources,
                           join_table: 'ext/roles'

  def email
    case provider
    when 'Slack'  then external_data.dig 'profile', 'email'
    when 'Jira'   then external_data.dig 'emailAddress'
    when 'Heroku' then external_data.dig 'user', 'email'
    when 'Google' then external_data.dig 'primaryEmail'
    when 'Asana'  then external_data.dig 'email'
    end
  end

  def avatar_url
    case provider
    when 'GitHub' then external_data['avatar_url']
    when 'Slack' then external_data.dig('profile', 'image_24')
    when 'Jira' then external_data.dig('avatarUrls', '24x24')
    when 'Asana' then external_data.dig 'photo', 'image_36x36'
    end || gravatar_url
  end

  def gravatar_url
    email_hash = Digest::MD5.hexdigest(email.downcase.strip)
    "https://www.gravatar.com/avatar/#{email_hash}"
  end
end
