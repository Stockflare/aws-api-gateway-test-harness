#!/usr/bin/env ruby
VERSION = "0.0.1"
require 'uri'
require 'net/http'
require 'pathname'
require 'fileutils'
require 'aws-sdk'
require 'csv'
require "base64"
require 'pry-byebug'



# Login to stockflare
uri = URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/users/login")
req = Net::HTTP::Post.new(uri)
req.body = {
  username: ENV['TEST_USER'],
  password: ENV['TEST_PASSWORD']
}.to_json
req.content_type = 'application/json'
login_resp = Net::HTTP.start(uri.hostname, uri.port,
                           use_ssl: uri.scheme == 'https') do |http|

  http.request(req)
end
login = JSON.parse(login_resp.body)

puts login.inspect

# Get Credentials for Identity
sts = Aws::STS::Client.new(region: ENV['AWS_REGION'])

creds = sts.assume_role_with_web_identity({
  role_arn: ENV['AUTHENTICATED_ROLE_ARN'],
  role_session_name: "login",
  web_identity_token: login['token'],
  duration_seconds: 900,
})

puts creds.inspect
