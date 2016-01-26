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
      let(:block_id) { JSON.parse(call_endpoint(uri, post_request).body)['id']}
      let(:update_request)  do
        req = Net::HTTP::Post.new(uri)
        req.body = {
            id: id,
            sic: "abdce1d5-8bcd-4692-af09-e77c0b20b3d3",
            watchlist_id: "foo",
            quantity: 888,
            price: 11.11,
            purchased: 100
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end
      it 'returns 201' do
        result = call_endpoint(uri, update_request)
        expect(result.code).to eql "201"
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

  describe 'post /properties' do
    let(:block_id) { JSON.parse(call_endpoint(uri, post_request).body)['id']}
    let(:properties_uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/blocks/properties") }
    let(:properties) {
      {
        "foo" => block_id
      }
    }
    let(:properties_post) do
      req = Net::HTTP::Post.new(properties_uri)
      req.body = {
          id: block_id,
          properties: properties
      }.to_json
      req.content_type = 'application/json'
      sign_request(req, credentials)
      req
    end
    let(:put_request) do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        ids: [block_id]
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
    let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/blocks?id=23c1ed4d-950d-4b70-b9c4-c117ba9dcbbf") }
    let(:delete_request)  do
      req = Net::HTTP::Delete.new(uri)
      req.content_type = 'application/json'
      req.body = {
          foo: 'bar'
      }.to_json
      sign_request(req, credentials)
      req
    end
    it 'returns 200' do
      # id = call_endpoint(uri, post_request)
      result = call_endpoint(uri, delete_request)
      expect(result.code).to eql "200"
    end

  end
end
