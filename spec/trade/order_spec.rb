require_relative '../spec_helper'

describe '/trade/order' do
  let(:base_uri) { URI.join("#{ENV['API_ENDPOINT']}") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:login_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/user/login")}
  let(:username) { 'dummy' }
  let(:broker) { 'dummy' }
  let(:account) { 'brkAcct1' }
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
  let(:nonce_key_2) do
    req = Net::HTTP::Get.new(nonce_uri)
    req.content_type = 'application/json'
    result = call_endpoint(nonce_uri, req)
    result['X-Replay-Nonce']
  end
  let(:login_result) do
    result = call_endpoint(login_uri, login_request)
    JSON.parse(result.body)
  end

  let(:action) { 'buy' }

  let(:quantity) { 10 }

  let(:type) { 'market' }

  let(:base_order) do
    {
      token: login_result['token'],
      broker: broker,
      account: account,
      action: action,
      quantity: quantity,
      ticker: 'aapl',
      expiration: 'day',
      type: type,
      stop_price: 0,
      limit_price: 0
    }
  end

  let(:order_extras) do
    {}
  end

  let(:order_params) do
    base_order.merge(order_extras)
  end

  describe 'PUT: /trade/order/positions' do
    let(:positions_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/order/positions")}
    let(:positions_request)  do
      req = Net::HTTP::Put.new(positions_uri)
      req.body = {
          token: login_result['token'],
          account: account,
          page: 0
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns positions' do
      result = call_endpoint(positions_uri, positions_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['quantity']).to be > 0
      expect(result['X-Total-Pages']).to eql '1'
      expect(result['X-Next-Page']).to eql nil
      expect(result['X-Previous-Page']).to eql nil
    end
  end

  describe 'PUT: /trade/order' do
    let(:order_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/order")}
    let(:order_request)  do
      req = Net::HTTP::Put.new(order_uri)
      req.body = {
          token: login_result['token']
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns orders' do
      result = call_endpoint(order_uri, order_request)
      expect(result.code).to eql "200"
    end
  end

  describe 'PUT: /trade/order/preview' do
    let(:preview_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/order/preview")}
    let(:preview_request)  do
      req = Net::HTTP::Post.new(preview_uri)
      req.body = order_params.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end

    it 'returns preview' do
      result = call_endpoint(preview_uri, preview_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['message']).to eql 'You are about to place a market order to buy AAPL'
    end
  end

  describe 'PUT: /trade/order/execute' do
    let(:preview_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/order/preview")}
    let(:execute_uri) { URI.join(base_uri, "/#{ENV['API_STAGE']}/trade/order/execute")}
    let(:preview_request)  do
      req = Net::HTTP::Post.new(preview_uri)
      req.body = order_params.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key
      sign_request(req, credentials)
      req
    end
    let(:execute_request)  do
      req = Net::HTTP::Post.new(execute_uri)
      req.body = {
        token: login_result['token'],
        broker: broker,
        account: account,
      }.to_json
      req.content_type = 'application/json'
      req['X-Replay-Nonce'] = nonce_key_2
      sign_request(req, credentials)
      req
    end

    it 'returns preview' do
      call_endpoint(preview_uri, preview_request)
      result = call_endpoint(execute_uri, execute_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['uuid']).not_to be_empty
    end
  end



end
