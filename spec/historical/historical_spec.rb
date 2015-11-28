require_relative '../spec_helper'

describe '/historical' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/historical") }
  let(:put_request)  do
    req = Net::HTTP::Put.new(uri)
    req.body = {
      sic: "6c8227be-6855-11e4-98bf-294717b2347c",
      after: 0,
      select: ["price", "rating"]
    }.to_json
    req.content_type = 'application/json'
    req
  end
  describe '/' do

    it 'returns 200' do
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['price']).to be > 0.0
      expect(JSON.parse(result.body)[0]['rating']).to be >= 0
    end

  end
end
