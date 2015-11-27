require_relative '../spec_helper'
require 'uri'
require 'net/http'
require 'pathname'
require 'fileutils'
require 'aws-sdk'
require 'csv'
require "base64"

describe '/directory/post' do
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }

  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/directory") }
  let(:request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
      properties: { foo: "bar" }

    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    puts req.inspect
    req
  end

  it 'returns 201' do
    expect(call_endpoint(uri, request).code).to eql "201"
  end

end
