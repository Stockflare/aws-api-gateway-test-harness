require_relative '../spec_helper'

describe '/payments/stripe' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/payments/#{endpoint}") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:plan) { 'silver' }

  describe '/payments/stripe/plans' do
    let(:endpoint) { 'stripe/plans'}
    let(:get_request)  do
      req = Net::HTTP::Get.new(uri)
      req.content_type = 'application/json'
      req
    end
    it 'returns 200' do
      result = call_endpoint(uri, get_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['id']).not_to be_empty
    end
  end

  describe '/payments/stripe/customer' do
    let(:endpoint) { 'stripe/customer'}

    describe 'PUT' do
      let(:put_request)  do
        req = Net::HTTP::Put.new(uri)
        req.body = {
          foo: 'bar'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, put_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body)['id']).not_to be_empty
      end
    end

    describe 'POST' do
      let(:post_request)  do
        req = Net::HTTP::Post.new(uri)
        req.body = {
          plan: plan,
          username: 'mark@stratmann.me.uk'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, post_request)
        expect(result.code).to eql "201"
        expect(JSON.parse(result.body)['id']).not_to be_empty
      end
    end

    describe 'DELETE' do
      let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/payments/#{endpoint}?plan=#{plan}") }
      let(:delete_request)  do
        req = Net::HTTP::Delete.new(uri)
        req.body = {
          foo: 'bar'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, delete_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body)['id']).not_to be_empty
      end
    end
  end

  describe '/payments/stripe/upgrade' do
    let(:endpoint) { 'stripe/upgrade'}

    describe 'POST' do
      let(:post_request)  do
        req = Net::HTTP::Post.new(uri)
        req.body = {
          plan: plan,
          source: 'foobar'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, post_request)
        expect(result.code).to eql "400"
        expect(JSON.parse(result.body)['error']['description']).to eql 'No such token: foobar'
      end
    end

  end
  describe '/payments/stripe/customer/plans' do
    let(:endpoint) { 'stripe/customer/plans'}

    describe 'PUT' do
      let(:put_request)  do
        req = Net::HTTP::Put.new(uri)
        req.body = {
          foo: 'bar'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, put_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body)[0]['id']).not_to be_empty
      end
    end
  end
end
