require_relative '../spec_helper'

describe '/alerts/observe' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/#{endpoint}") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:sic) { '6c8227be-6855-11e4-98bf-294717b2347c' }

  describe '/alerts/observe' do
    let(:endpoint) { 'alerts/observe'}


    describe 'POST' do
      let(:post_request)  do
        req = Net::HTTP::Post.new(uri)
        req.body = {
          sic: sic,
          language: 'en'
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, post_request)
        expect(result.code).to eql "201"
        expect(JSON.parse(result.body)['sic']).to eql sic
      end
    end

    describe 'DELETE' do
      let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/#{endpoint}?sic=#{sic}") }
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
      end
    end
  end

  describe '/alerts/observe/observing' do
    let(:endpoint) { 'alerts/observe/observing'}


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
        pp JSON.parse(result.body)
        expect(result.code).to eql "200"
      end
    end

  end


end
