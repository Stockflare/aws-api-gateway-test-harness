require_relative '../spec_helper'

describe '/portfolios' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/portfolios") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:id) { "" }
  let(:post_request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
        type: "memo"
    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  describe '/post' do

    it 'returns 201' do
      result = call_endpoint(uri, post_request)
      expect(result.code).to eql "201"
      expect(JSON.parse(result.body)['type']).to eql "memo"

    end

  end

  describe '/put-get' do
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        "foo": "bar"
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end

    it 'will return property' do
      call_endpoint(uri, post_request)
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).first['type']).to eql 'memo'
    end

  end

  describe 'post /properties' do
    let(:portfolio_id) { JSON.parse(call_endpoint(uri, post_request).body)['id']}
    let(:properties_uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/portfolios/properties") }
    let(:properties) {
      {
        "foo" => portfolio_id
      }
    }
    let(:properties_post) do
      req = Net::HTTP::Post.new(properties_uri)
      req.body = {
          id: portfolio_id,
          properties: properties
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        ids: [portfolio_id]
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end

    it 'will return properties' do
      put_properties_result = call_endpoint(properties_uri, properties_post)
      expect(put_properties_result.code).to eql "201"
      result = call_endpoint(properties_uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).first['properties']).to eql properties
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
