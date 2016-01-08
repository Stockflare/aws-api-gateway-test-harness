require_relative '../spec_helper'

describe '/blocks' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/blocks") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:id) { "" }
  let(:post_request)  do
    req = Net::HTTP::Post.new(uri)
    req.body = {
        id: id,
        sic: "abdce1d5-8bcd-4692-af09-e77c0b20b3d3",
        watchlist_id: "foo",
        quantity: 999,
        price: 11.11,
        purchased: 100
    }.to_json
    req.content_type = 'application/json'
    sign_request(req, credentials)
    req
  end
  describe '/post' do

    it 'returns 201' do
      result = call_endpoint(uri, post_request)
      expect(result.code).to eql "201"
      expect(JSON.parse(result.body)['sic']).to eql "abdce1d5-8bcd-4692-af09-e77c0b20b3d3"

    end

    describe 'update existing block' do
      let(:id) { "7874c9a7-f875-4059-81ba-5f3f6974df76" }
      it 'returns 201' do
        expect(call_endpoint(uri, post_request).code).to eql "201"
      end
    end

    describe 'try to update another users id' do
      let(:id) { "bbc91620-7d03-41d6-ab8d-0be31c7a55e6" }

      it 'returns 403' do
        expect(call_endpoint(uri, post_request).code).to eql "403"
      end
    end
  end

  describe '/put-get' do
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        watchlist_id: "foo"
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end

    it 'will return property' do
      call_endpoint(uri, post_request)
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).first['sic']).to eql 'abdce1d5-8bcd-4692-af09-e77c0b20b3d3'
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
