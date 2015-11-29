require_relative '../spec_helper'

describe '/exchanges' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/exchanges/") }
  let(:put_request)  do
    req = Net::HTTP::Put.new(uri)
    req.body = {
      codes: ["lse", "dix"]
    }.to_json
    req.content_type = 'application/json'
    req
  end
  describe '/' do

    it 'returns 200' do
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).count).to eql 2
    end
  end

end
