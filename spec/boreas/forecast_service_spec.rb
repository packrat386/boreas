require "spec_helper"

# These specs are a bit more reliant on fixtures than I would like. To me
# that indicates that maybe these should be chunked out into their own
# little services. I've been messing with these particular APIs for long
# enough that I'm pretty confident it works anyway though.

RSpec.describe Boreas::ForecastService do
  let(:service) { described_class.new(search_address) }

  describe "#forecast_data" do
    let(:search_address) { "1600 Pennsylvania Avenue, Washington DC" }
    subject { service.forecast_data }

    before do
      stub_request(
        :get,
        "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=1600%20Pennsylvania%20Avenue,%20Washington%20DC&benchmark=2020&format=json"
      ).to_return(
        status: 200,
        body: file_fixture("geocode_white_house.json")
      )

      stub_request(
        :get,
        "https://api.weather.gov/points/38.8988,-77.0353"
      ).to_return(
        status: 200,
        body: file_fixture("nws_points_white_house.json")
      )

      stub_request(
        :get,
        "https://api.weather.gov/gridpoints/LWX/97,71/forecast"
      ).to_return(
        status: 200,
        body: file_fixture("nws_forecast_white_house.json")
      )

      stub_request(
        :get,
        "https://api.weather.gov/gridpoints/LWX/97,71/forecast/hourly"
      ).to_return(
        status: 200,
        body: file_fixture("nws_forecast_hourly_white_house.json")
      )
    end

    let(:expected_format) { JSON.parse(file_fixture("forecast_expected_format.json").read) }

    it "generates the expected data format" do
      expect(subject).to eq(expected_format)
    end

    context "when there is no matching address" do
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
        expect { subject }.to raise_error(Boreas::ForecastService::NoMatchingAddressError)
      end
    end

    context "when geocoding service errors" do
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
        expect { subject }.to raise_error(Boreas::ForecastService::APIError)
      end
    end

    context "when forecast service errors" do
      before do
        stub_request(
          :get,
          "https://api.weather.gov/gridpoints/LWX/97,71/forecast"
        ).to_return(
          status: 500,
          body: {"ruh" => "roh"}.to_json
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::ForecastService::APIError)
      end
    end
  end

  describe "#alert_data" do
    let(:search_address) { "1107 Douglas Ave, Beaver, OK 73932" }
    subject { service.alert_data }

    before do
      stub_request(
        :get,
        "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=1107+Douglas+Ave%2C+Beaver%2C+OK+73932&benchmark=2020&format=json"
      ).to_return(
        status: 200,
        body: file_fixture("geocode_beaver_county_fair.json")
      )

      stub_request(
        :get,
        "https://api.weather.gov/alerts/active?point=36.806%2C-100.5196"
      ).to_return(
        status: 200,
        body: file_fixture("nws_alerts_beaver_county_fair.json")
      )
    end

    let(:expected_format) { JSON.parse(file_fixture("alert_expected_format.json").read) }

    it "generates the expected data format" do
      expect(subject).to eq(expected_format)
    end

    context "when geocoding service errors" do
      before do
        stub_request(
          :get,
          "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=1107+Douglas+Ave%2C+Beaver%2C+OK+73932&benchmark=2020&format=json"
        ).to_return(
          status: 500,
          body: {"ruh" => "roh"}.to_json
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::ForecastService::APIError)
      end
    end

    context "when forecast service errors" do
      before do
        stub_request(
          :get,
          "https://api.weather.gov/alerts/active?point=36.806%2C-100.5196"
        ).to_return(
          status: 500,
          body: {"ruh" => "roh"}.to_json
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(Boreas::ForecastService::APIError)
      end
    end
  end
end
