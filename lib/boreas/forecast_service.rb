module Boreas
  class ForecastService
    include RequestHelper

    def initialize(address)
      @geocoding_service = GeocodingService.new(address)
    end

    def forecast_data
      daily_data = get_json_cached(daily_forecast_url, 5.minutes)
        .dig("properties", "periods")
        .map { it.slice("name", "startTime", "endTime", "temperature", "shortForecast", "detailedForecast").merge("hourlyData" => []) }

      get_json_cached(hourly_forecast_url, 5.minutes).dig("properties", "periods").each do |hd|
        daily_data.each do |dd|
          if (Time.zone.parse(dd["startTime"]) <= Time.zone.parse(hd["startTime"])) && (Time.zone.parse(dd["endTime"]) >= Time.zone.parse(hd["endTime"]))
            dd["hourlyData"] << hd.slice("startTime", "temperature", "windSpeed", "windDirection", "shortForecast")
          end
        end
      end

      daily_data
    end

    def alert_data
      get_json_cached(alert_url, 5.minutes)
        .dig("features").map { it.dig("properties").slice("headline", "description", "instruction") }
    end

    def alert_url
      URI::HTTPS.build(
        host: "api.weather.gov",
        path: "/alerts/active",
        query: {
          point: point
        }.to_query
      ).to_s
    end

    def daily_forecast_url
      nws_gridpoint.dig("properties", "forecast")
    end

    def hourly_forecast_url
      nws_gridpoint.dig("properties", "forecastHourly")
    end

    def nws_gridpoint
      @nws_gridpoint ||= get_json_cached("https://api.weather.gov/points/#{point}", 1.day)
    end

    def point
      @point ||= @geocoding_service.point
    end
  end
end
