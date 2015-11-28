require_relative '../spec_helper'

describe '/directory' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/directory") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:post_request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
      properties: { foo: "bar" }

    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  describe '/post' do

    it 'returns 201' do
      expect(call_endpoint(uri, post_request).code).to eql "201"

    end

  end

  describe '/put-get' do
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        identities: [ login['identity'] ],
        keys: [ 'foo' ]
      }.to_json
      req.content_type = 'application/json'
      req
    end

    it 'will return property' do
      call_endpoint(uri, post_request)
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[login['identity']]['foo']).to eql 'bar'
    end
  end

  describe '/delete' do
    let(:delete_request)  do
      req = Net::HTTP::Delete.new(uri)
      req.body = {
        keys: [ 'foo' ]
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end
    it 'returns 201' do
      call_endpoint(uri, post_request)
      result = call_endpoint(uri, delete_request)
      expect(result.code).to eql "200"
    end

  end
end
