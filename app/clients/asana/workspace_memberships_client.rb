require 'net/http'

module Asana
  class WorkspaceMembershipsClient
    def self.index(token, workspace_id) = new(token).index(workspace_id)
    def self.show(token, workspace_membership_id) = new(token).show(workspace_membership_id)

    def initialize(token) = @token = token

    def index(workspace_id)
      uri = URI.parse "https://app.asana.com/api/1.0/workspaces/#{workspace_id}/workspace_memberships"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end

    def show(workspace_membership_id)
      uri = URI.parse "https://app.asana.com/api/1.0/workspace_memberships/#{workspace_membership_id}"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end
