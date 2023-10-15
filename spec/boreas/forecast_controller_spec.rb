require "spec_helper"

RSpec.describe Boreas::ForecastController, type: :feature do
  describe "getting a forecast" do
    let(:forecast_service) do
      instance_double(
        Boreas::ForecastService,
        alert_data: alert_data,
        forecast_data: forecast_data
      )
    end

    let(:alert_data) { nil }

    let(:forecast_data) do
      [
        {
          "name" => "New Year's Day",
          "startTime" => "2023-01-01T12:00:00-05:00",
          "endTime" => "2023-01-01T18:00:00-05:00",
          "temperature" => 65,
          "shortForecast" => "Mostly Sunny",
          "detailedForecast" => "Mostly sunny. High near 65, with temperatures falling to around 57 in the afternoon. West wind 2 to 6 mph.",
          "hourlyData" => [
            {
              "startTime" => "2023-01-01T12:00:00-05:00",
              "temperature" => 60,
              "windSpeed" => "6 mph",
              "windDirection" => "NW",
              "shortForecast" => "Sunny"
            },
            {
              "startTime" => "2023-01-01T13:00:00-05:00",
              "temperature" => 63,
              "windSpeed" => "5 mph",
              "windDirection" => "W",
              "shortForecast" => "Mostly Sunny"
            },
            {
              "startTime" => "2023-01-01T14:00:00-05:00",
              "temperature" => 65,
              "windSpeed" => "3 mph",
              "windDirection" => "W",
              "shortForecast" => "Mostly Sunny"
            },
            {
              "startTime" => "2023-01-01T15:00:00-05:00",
              "temperature" => 63,
              "windSpeed" => "3 mph",
              "windDirection" => "W",
              "shortForecast" => "Partly Sunny"
            }
          ]
        }
      ]
    end

    let(:search_address) { "1600 Pennsylvania Avenue, Washington DC" }

    before do
      allow(Boreas::ForecastService).to receive(:new).and_return(forecast_service)
    end

    it "defaults to no address" do
      visit forecast_path

      expect(Boreas::ForecastService).not_to have_received(:new)

      expect(page).to have_content "Forecast"

      expect(page).to have_field "Address", type: "text", with: ""
      expect(page).to have_button "Submit"

      expect(page).not_to have_selector "#forecast"
    end

    it "searches by address" do
      visit forecast_path

      fill_in "Address", with: search_address
      click_button "Submit"

      expect(Boreas::ForecastService).to have_received(:new).with search_address

      expect(page).to have_content "Forecast"

      expect(page).to have_field "Address", type: "text", with: search_address

      expect(page).to have_selector "#forecast"
      expect(page).to have_content "New Year's Day (1/1): 65°F - Mostly Sunny"
    end

    it "takes the address as a URL parameter" do
      visit forecast_path(address: search_address)

      expect(Boreas::ForecastService).to have_received(:new).with search_address

      expect(page).to have_content "Forecast"

      expect(page).to have_field "Address", type: "text", with: search_address

      expect(page).to have_selector "#forecast"
      expect(page).to have_content "New Year's Day (1/1): 65°F - Mostly Sunny"
    end

    it "renders errors" do
      visit forecast_path

      allow(forecast_service).to receive(:forecast_data).and_raise("something went wrong")

      fill_in "Address", with: search_address
      click_button "Submit"

      expect(Boreas::ForecastService).to have_received(:new).with search_address

      expect(page).to have_content "Forecast"

      expect(page).to have_field "Address", type: "text", with: search_address

      expect(page).not_to have_selector "#forecast"
      expect(page).to have_content "ruh roh: something went wrong"
    end

    context "with alerts" do
      let(:alert_data) do
        [
          {
            "headline" => "Freeze Warning issued October 15 at 9:52AM CDT until October 16 at 9:00AM CDT by NWS Amarillo TX",
            "description" => "* WHAT...Sub-freezing temperatures as low as 32 expected.\n\n* WHERE...In Oklahoma, Beaver County. In Texas, Ochiltree County.\n\n* WHEN...From 4 AM to 9 AM CDT Monday.\n\n* IMPACTS...Frost and freeze conditions could kill crops, other\nsensitive vegetation and possibly damage unprotected outdoor\nplumbing.",
            "instruction" => "Take steps now to protect tender plants from the cold."
          }
        ]
      end

      it "renders alerts" do
        visit forecast_path(address: search_address)

        expect(Boreas::ForecastService).to have_received(:new).with search_address

        expect(page).to have_content "Forecast"

        expect(page).to have_field "Address", type: "text", with: search_address

        expect(page).to have_selector "#forecast"
        expect(page).to have_content "New Year's Day (1/1): 65°F - Mostly Sunny"
      end
    end
  end
end
