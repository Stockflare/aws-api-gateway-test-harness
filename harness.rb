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


def sign_request(req, credentials)
  # Create a AWS Style request
  aws_req = Seahorse::Client::Http::Request.new(
    endpoint: req.uri,
    http_method: req.method,
    body: req.body
  )

  # Sign the request
  signer = Aws::Signers::V4.new(credentials, 'execute-api', ENV['AWS_REGION'])
  signer.sign(aws_req)

  # Patch in all the signing headers
  aws_req.headers.each do |key, val|
    puts key
    puts val
    req[key] = val
  end

  req
end

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

# Create directory request
uri = URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/directory")
req = Net::HTTP::Post.new(uri)
req.body = {
  properties: { foo: "bar" }

}.to_json
req.content_type = 'application/json'

sign_request(req, creds)

puts req.inspect

# Call directory with signed endpoint
dir_resp = Net::HTTP.start(uri.hostname, uri.port,
                           use_ssl: uri.scheme == 'https') do |http|

  http.request(req)
end

puts dir_resp
