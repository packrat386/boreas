require "net/http"

module Boreas
  class ForecastService
    class NoMatchingAddressError < StandardError; end

    class APIError < StandardError; end

    def initialize(address)
      @search_address = address
    end

    def forecast_data
      daily_data = get_json_cached(daily_forecast_url, 5.minutes)
        .dig("properties", "periods")
        .map { _1.slice("name", "startTime", "endTime", "temperature", "shortForecast", "detailedForecast").merge("hourlyData" => []) }

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
        .dig("features").map { _1.dig("properties").slice("headline", "description", "instruction") }
    end

    def alert_url
      URI::HTTPS.build(
        host: "api.weather.gov",
        path: "/alerts/active",
        query: {
          point: "#{latitude},#{longitude}"
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
      @nws_gridpoint ||= get_json_cached("https://api.weather.gov/points/#{latitude},#{longitude}", 1.day)
    end

    def latitude
      matched_address.dig("coordinates", "y").round(4)
    end

    def longitude
      matched_address.dig("coordinates", "x").round(4)
    end

    def matched_address
      return @matched_address if defined?(@matched_address)

      addresses = get_json_cached(geocoding_url, 1.day).dig("result", "addressMatches")

      raise NoMatchingAddressError.new("no coordinates found matching address: #{@search_address}") if addresses.blank?
      @matched_address = addresses.first
    end

    def geocoding_url
      URI::HTTPS.build(
        host: "geocoding.geo.census.gov",
        path: "/geocoder/locations/onelineaddress",
        query: {
          address: @search_address,
          benchmark: 2020,
          format: "json"
        }.to_query
      ).to_s
    end

    def get_json_cached(url, exp)
      data = Rails.cache.read(url.to_s)
      if data.present?
        Rails.logger.debug("using cached data for: #{url}")
        return data
      end

      Rails.logger.debug("fetching: #{url}")
      data = get_json(url)
      Rails.cache.write(url.to_s, data, expires_in: exp)

      data
    end

    def get_json(url)
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "Boreas / #{Boreas::VERSION} (beta)"

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      if res.code != "200"
        Rails.logger.debug("call to #{url} errored: #{res.code} -> #{res.body}")
        raise APIError.new("call to API: #{url} got error code: #{res.code}")
      end

      JSON.parse(res.body)
    end
  end
end
