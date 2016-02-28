require_relative '../spec_helper'

describe '/directory' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/explore") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:post_request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
      conditions: { foo: "bar" }

    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  describe '/post' do

    it 'returns 201' do
      result = call_endpoint(uri, post_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['conditions']['foo']).to eql 'bar'

    end

  end

  describe '/delete' do
    let(:uuid) do
      post_result = call_endpoint(uri, post_request)
      JSON.parse(post_result.body)['uuid']
    end
    let(:delete_request)  do
      req = Net::HTTP::Delete.new(uri)
      req.body = {
        uuid: uuid
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end
    it 'returns 201' do
      result = call_endpoint(uri, delete_request)
      expect(result.code).to eql "200"
    end

  end
end
