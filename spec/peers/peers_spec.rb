require_relative '../spec_helper'

describe '/' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/peers/?sic=#{sic}") }
  let(:sic) { "6c8227be-6855-11e4-98bf-294717b2347c" }

  let(:peers_request)  do
    req = Net::HTTP::Get.new(uri)
    req.content_type = 'application/json'
    req
  end

  describe '/' do
    it 'returns 200 and peers' do
      result = call_endpoint(uri, peers_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body).count).to be > 2
    end
  end

  describe 'aggregate/' do
    let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/peers/aggregate?sic=#{sic}&type=avg&field=price") }

    it 'returns 200 and price' do
      result = call_endpoint(uri, peers_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['price']['value']).to be > 0.0
    end
  end



end
