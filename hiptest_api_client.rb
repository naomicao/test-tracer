require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'pry'

class HipTestApiClient

  def initialize(project_id)
    raise "Please set the env var 'ACCESS_TOKEN'" unless ENV['HT_ACCESS_TOKEN']
    raise "Please set the env var 'CLIENT_ID'" unless ENV['HT_CLIENT_ID']
    raise "Please set the env var 'HT_UID'" unless ENV['HT_UID']

    @access_token = ENV['HT_ACCESS_TOKEN']
    @client_id = ENV['HT_CLIENT_ID']
    @uid = ENV['HT_UID']
    @base_url = "https://app.hiptest.com/api"
    @project_url = @base_url + "/projects/#{project_id}"
  end

  def update_scenario(scenario_id:, description:)
    uri = URI("#{@project_url}/scenarios/#{scenario_id}")
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = true

    req = build_patch_request(uri)
    req.body = build_request_body(scenario_id, description).to_json
    res = conn.request(req)
    res_body = JSON.parse(res.body)
    raise res.code unless res.kind_of? Net::HTTPSuccess
  end

  private

  def build_request_body(scenario_id, description)
    {"data": {"type": "scenarios", "id": scenario_id, "attributes": {"description": description}}}
  end

  def build_patch_request(uri)
    req = Net::HTTP::Patch.new(uri)
    req["Accept"] = 'application/vnd.api+json; version=1'
    req["access-token"] = @access_token
    req["client"] = @client_id
    req["uid"] = @uid

    req
  end
end
