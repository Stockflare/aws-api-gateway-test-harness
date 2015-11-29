require_relative '../spec_helper'

describe '/sectors' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/sectors/") }
  let(:put_request)  do
    req = Net::HTTP::Put.new(uri)
    req.body = {
      codes: ["50", "51"]
    }.to_json
    req.content_type = 'application/json'
    req
  end
  describe '/' do

    it 'returns 200' do
      result = call_endpoint(uri, put_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['code']).to eql "50"
      expect(JSON.parse(result.body).count).to eql 2
    end
  end

  describe 'gets' do
    let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/sectors/#{action}?code=#{code}") }
    let(:code) { "5010" }
    let(:get_request)  do
      req = Net::HTTP::Get.new(uri)
      req.content_type = 'application/json'
      req
    end

    describe '/parent' do
      let(:action) { "parent"}
      it 'returns 200' do
        result = call_endpoint(uri, get_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body).count).to be >= 1
      end
    end
    describe '/siblings' do
      let(:action) { "siblings"}
      it 'returns 200' do
        result = call_endpoint(uri, get_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body).count).to be >= 1
      end
    end
    describe '/children' do
      let(:action) { "children"}
      it 'returns 200' do
        result = call_endpoint(uri, get_request)
        expect(result.code).to eql "200"
        expect(JSON.parse(result.body).count).to be >= 1
      end
    end
  end
end
