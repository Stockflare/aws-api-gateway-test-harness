require_relative '../spec_helper'

describe '/search' do
  let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/search") }

  let(:search_request)  do
    req = Net::HTTP::Put.new(uri)
    req.body = {
      term: "Apple Inc",
      select: "_all"

    }.to_json
    req.content_type = 'application/json'
    req
  end

  describe '/' do
    it 'returns 200 and Apple' do
      result = call_endpoint(uri, search_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['ric']).to eql "aapl.o"
    end
  end

  describe '/filter' do
    let(:uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/search/filter") }

    let(:search_request)  do
      req = Net::HTTP::Put.new(uri)
      req.body = {
        conditions: { "ric": "aapl.o"},
        select: [ "ric", "sic"]

      }.to_json
      req.content_type = 'application/json'
      req
    end
    it 'returns 200 and Apple' do
      result = call_endpoint(uri, search_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)[0]['ric']).to eql "aapl.o"
    end
  end

  describe '/aggregate' do
    let(:aggregate_uri) { URI.join("#{ENV['API_ENDPOINT']}/#{ENV['API_STAGE']}/search/aggregate") }
    let(:aggregate_request)  do
      req = Net::HTTP::Put.new(aggregate_uri)
      req.body = {
        conditions: { "ric": "aapl.o" },
        field: "price",
        type: "sum"
      }.to_json
      req.content_type = 'application/json'
      req
    end
    it 'returns 200 and Apple' do
      price = JSON.parse(call_endpoint(uri, search_request).body)[0]['price']
      result = call_endpoint(aggregate_uri, aggregate_request)
      expect(result.code).to eql "200"
      expect(JSON.parse(result.body)['price']['value']).to eql price
    end
  end




end
