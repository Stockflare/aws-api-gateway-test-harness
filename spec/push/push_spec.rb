require_relative '../spec_helper'

describe '/push/messages' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/#{endpoint}") }
  let(:login) { login_user(ENV['TEST_USER'], ENV['TEST_PASSWORD']) }
  let(:credentials) { get_credentials(login) }
  let(:sic) { '6c8227be-6855-11e4-98bf-294717b2347c' }

  describe '/push/messages' do
    let(:endpoint) { 'push/messages'}


    describe 'PUT' do
      let(:put_request)  do
        req = Net::HTTP::Put.new(uri)
        req.body = {
          before: Time.now.utc.to_i,
          after: 0
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, put_request)
        expect(result.code).to eql "200"
      end
    end
  end

  describe '/push/messages/acknowledge' do
    let(:endpoint) { 'push/messages/acknowledge'}


    describe 'POST' do
      let(:post_request)  do
        req = Net::HTTP::Post.new(uri)
        req.body = {
          sent_at: Time.now.utc.to_i
        }.to_json
        req.content_type = 'application/json'
        sign_request(req, credentials)
        req
      end

      specify do
        result = call_endpoint(uri, post_request)
        binding.pry
        expect(result.code).to eql "201"
      end
    end
  end


end
