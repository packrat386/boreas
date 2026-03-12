require "spec_helper"

RSpec.describe Boreas::GeocodingService do
  let(:service) { described_class.new(search_address) }
  subject { service.point }

  describe "address string" do
    let(:search_address) { "1600 Pennsylvania Avenue, Washington DC" }

    describe "happy path" do
      before do
        stub_request(
          :get,
          "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=1600%20Pennsylvania%20Avenue,%20Washington%20DC&benchmark=2020&format=json"
        ).to_return(
          status: 200,
          body: file_fixture("geocode_white_house.json")
        )
      end

      it "returns a point" do
        expect(subject).not_to be_nil
        expect(subject.latitude).to eq(38.8988)
        expect(subject.longitude).to eq(-77.0353)
        expect(subject.to_s).to eq("38.8988,-77.0353")
      end
    end

    describe "no matching address" do
      let(:search_address) { "notanaddress" }

      before do
        stub_request(
          :get,
          "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=notanaddress&benchmark=2020&format=json"
        ).to_return(
          status: 200,
          body: file_fixture("geocode_no_match.json")
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::Errors::NoMatchingAddressError)
      end
    end

    describe "request error" do
      before do
        stub_request(
          :get,
          "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=1600%20Pennsylvania%20Avenue,%20Washington%20DC&benchmark=2020&format=json"
        ).to_return(
          status: 500,
          body: {"ruh" => "roh"}.to_json
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::Errors::APIError)
      end
    end
  end

  describe "zip code" do
    describe "happy path" do
      let(:search_address) { "62701" }

      it "returns a point" do
        expect(subject).not_to be_nil
        expect(subject.latitude).to eq(39.8)
        expect(subject.longitude).to eq(-89.6495)
        expect(subject.to_s).to eq("39.8,-89.6495")
      end
    end

    describe "no matching zip code" do
      let(:search_address) { "00000" }

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::Errors::NoMatchingAddressError)
      end
    end
  end
end
