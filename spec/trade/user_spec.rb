require_relative '../spec_helper'

describe '/trade/user' do
  let(:base_uri) { URI.join("#{ENV['API_ENDPOINT']}") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:login_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/login")}
  let(:username) { 'dummy' }
  let(:broker) { 'dummy' }
  let(:login_request)  do
    req = Net::HTTP::Post.new(login_uri)
    req.body = {
        broker: broker,
        username: username,
        password: "pass"
    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  let(:nonce_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade")}
  let(:nonce_key) do
    req = Net::HTTP::Get.new(nonce_uri)
    req.content_type = 'application/json'
    result = call_endpoint(nonce_uri, req)
    result['X-Replay-Nonce']
  end
  let(:login_result) do
    result = call_endpoint(login_uri, login_request)
    JSON.parse(result.body)
  end

  describe 'POST: /trade/user/login' do

    it 'returns 201' do
      result = call_endpoint(login_uri, login_request)
      expect(result.code).to eql "201"
      expect(JSON.parse(result.body)['token']).not_to be_empty
      expect(JSON.parse(result.body)['type']).to eql 'success'

    end

    describe 'login needing verification' do
      let(:username) { 'dummySecurity' }

      it 'returns a verification response' do
        result = call_endpoint(login_uri, login_request)
        expect(result.code).to eql "201"
        expect(JSON.parse(result.body)['token']).not_to be_empty
        expect(JSON.parse(result.body)['type']).to eql 'verify'
      end
    end
  end


  describe 'POST: /trade/user/refresh' do
    let(:refresh_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/refresh")}
    let(:refresh_request)  do
      req = Net::HTTP::Post.new(refresh_uri)
      req.body = {
          token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end

    it 'returns noop refreshed session' do
      result = call_endpoint(refresh_uri, refresh_request)
      expect(result.code).to eql "201"
      expect(JSON.parse(result.body)['token']).not_to be_empty
      expect(JSON.parse(result.body)['type']).to eql 'success'
      expect(result['X-Session-Refreshed']).to eql 'noop'
      expect(result['X-Session-TTL']).to eql '1800'
    end
  end

  describe 'PUT: /trade/user/accounts' do
    let(:accounts_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/accounts")}
    let(:accounts_request)  do
      req = Net::HTTP::Put.new(accounts_uri)
      req.body = {
          dummy_force_login_token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns accounts' do
      result = call_endpoint(accounts_uri, accounts_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['id']).not_to be_empty
    end
  end

  describe 'PUT: /trade/user/links' do
    let(:links_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/links")}
    let(:links_request)  do
      req = Net::HTTP::Put.new(links_uri)
      req.body = {
          dummy_force_login_token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns links' do
      result = call_endpoint(links_uri, links_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).count).to be > 0
    end
  end

  describe 'POST: /trade/user/verify' do
    let(:username) { 'dummySecurity' }
    let(:verify_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/verify")}
    let(:verify_request)  do
      req = Net::HTTP::Post.new(verify_uri)
      req.body = {
          broker: broker,
          token: login_result['token'],
          answer: 'tradingticket'
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns verify' do
      result = call_endpoint(verify_uri, verify_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['token']).not_to be_empty
      expect(JSON.parse(result.body)['type']).to eql 'success'
    end
  end

  describe 'DELETE: /trade/user/logout' do
    let(:logout_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/logout")}
    let(:logout_request)  do
      req = Net::HTTP::Delete.new(logout_uri)
      req.body = {
          broker: broker,
          token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns logout' do
      result = call_endpoint(logout_uri, logout_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['token']).not_to be_empty
      expect(JSON.parse(result.body)['type']).to eql 'success'
    end
  end

  describe 'DELETE: /trade/user/unlink' do
    let(:logout_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/unlink")}
    let(:logout_request)  do
      req = Net::HTTP::Delete.new(logout_uri)
      req.body = {
          broker: broker,
          token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns logout' do
      result = call_endpoint(logout_uri, logout_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['token']).not_to be_empty
      expect(JSON.parse(result.body)['type']).to eql 'success'
    end
  end

end
