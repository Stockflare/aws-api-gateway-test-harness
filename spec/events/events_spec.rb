require_relative '../spec_helper'

describe '/events' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/events") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:id) { "" }
  let(:post_request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
        type: "test",
        data: {
          foo: 'bar'
        }
    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  describe '/post' do

    it 'returns 201' do
      result = call_endpoint(uri, post_request)
      binding.pry
      expect(result.code).to eql "201"
      expect(JSON.parse(result.body)['type']).to eql "test"

    end

  end

  describe '/put-get' do
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        "after": 0
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end

    it 'will return property' do
      call_endpoint(uri, post_request)
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).first['type']).to eql 'test'
    end

  end

end
