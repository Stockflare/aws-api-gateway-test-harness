require 'aws-sdk'
require 'uri'
require 'net/http'

module Helpers
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
      req[key] = val
    end
    req
  end

  def login_user(user, password)
    # Login to stockflare
    uri = URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/users/login")
    req = Net::HTTP::Post.new(uri)
    req.body = {
      username: user,
      password: password
    }.to_json
    req.content_type = 'application/json'
    login_resp = Net::HTTP.start(uri.hostname, uri.port,
                               use_ssl: uri.scheme == 'https') do |http|

      http.request(req)
    end
    login = JSON.parse(login_resp.body)
    login
  end

  def get_credentials(login)
    sts = Aws::STS::Client.new(region: ENV['AWS_REGION'])
    creds = sts.assume_role_with_web_identity({
      role_arn: ENV['AUTHENTICATED_ROLE_ARN'],
      role_session_name: "login",
      web_identity_token: login['token'],
      duration_seconds: 900,
    })
    creds
  end

  def call_endpoint(uri, request)
    dir_resp = Net::HTTP.start(uri.hostname, uri.port,
                               use_ssl: uri.scheme == 'https') do |http|

      http.request(request)
    end
    # binding.pry
    dir_resp
  end
end
