require "spec_helper"

RSpec.describe Boreas::ForecastService do
  let(:service) { described_class.new(search_address) }
  let(:geocoding_service) { instance_double(Boreas::GeocodingService, point: point) }
  before { allow(Boreas::GeocodingService).to receive(:new).and_return(geocoding_service) }

  describe "#forecast_data" do
    let(:point) { Boreas::GeocodingService::Point.new(latitude: 38.8988, longitude: -77.0353) }
    let(:search_address) { "1600 Pennsylvania Avenue, Washington DC" }
    subject { service.forecast_data }

    before do
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

    context "when geocoding service errors" do
      before do
        allow(geocoding_service).to receive(:point).and_raise("ah beans")
      end

      it "raises through error" do
        expect { subject }.to raise_error(/ah beans/)
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
        expect { subject }.to raise_error(Boreas::Errors::APIError)
      end
    end
  end

  describe "#alert_data" do
    let(:search_address) { "1107 Douglas Ave, Beaver, OK 73932" }
    let(:point) { Boreas::GeocodingService::Point.new(latitude: 36.806, longitude: -100.5196) }
    subject { service.alert_data }

    before do
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
        allow(geocoding_service).to receive(:point).and_raise("ah beans")
      end

      it "raises an error" do
        expect { subject }.to raise_error(/ah beans/)
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
        expect { subject }.to raise_error(Boreas::Errors::APIError)
      end
    end
  end
end
