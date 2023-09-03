require "application_system_test_case"

class Xapp::RedirectsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    Ext::Bot.destroy_all
    Ext::Resource.destroy_all

    @account__user = account_users(:one)
    sign_in @account__user
  end

  test 'to home page' do
    VCR.insert_cassettes [
      'providers.git_hub.bot_access_token_client#create',
      'providers.git_hub.installation_access_token_client#create',
      'providers.git_hub.installation_client.show',
      'providers.git_hub.members_client.index',
      'providers.git_hub.outside_collaborators_client.index'
    ] do
      git_hub_creds = Rails.application.credentials.providers.git_hub

      visit url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'GitHub',
          installation_id: git_hub_creds.bot.id,
          setup_action: 'install' }
      ]

      @account__user.company.ext__resources.each do |resource|
        assert_text resource.name
        resource.personas.each do |persona|
          find('img'){ _1['src'] == persona.avatar_url }
          assert_text persona.name
        end
      end
    end

    Ext::Resource.destroy_all
    Ext::Persona.destroy_all
    visit root_path

    VCR.insert_cassettes [
      'providers.git_hub.members_client.index',
      'providers.git_hub.outside_collaborators_client.index'
    ] do
      click_button 'Reaudit'

      @account__user.company.ext__resources.each do |resource|
        assert_text resource.name
        resource.personas.each do |persona|
          find('img'){ _1['src'] == persona.avatar_url }
          assert_text persona.name
        end
      end
    end
  end
end
