require_relative '../spec_helper'

describe '/currency' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/currency/?from=#{from}") }
  let(:from) { 'eur' }
  let(:get_request)  do
    req = Net::HTTP::Get.new(uri)
    req.content_type = 'application/json'
    req
  end
  describe '/' do

    it 'returns 200 and currency' do
      result = call_endpoint(uri, get_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['from']).to eql "eur"
      expect(JSON.parse(result.body)[0]['to']).to eql "usd"
      expect(JSON.parse(result.body)[0]['rate']).to be >  0.0
    end

  end
end
