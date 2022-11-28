require 'net/http'

module Boreas
  class ForecastService
    class NoMatchingAddressError < StandardError; end

    def initialize(address)
      @search_address = address
    end

    def forecast_data
      get_json(hourly_forecast_url).dig('properties')
    end

    def hourly_forecast_url
      get_json("https://api.weather.gov/points/#{latitude},#{longitude}").dig('properties', 'forecastHourly')
    end

    def latitude
      matched_address.dig('coordinates', 'y').round(4)
    end

    def longitude
      matched_address.dig('coordinates', 'x').round(4)
    end

    def matched_address
      addresses = get_json(geocoding_url).dig('result', 'addressMatches')

      raise NoMatchingAddressError.new("No coordinates found matching address: #{@search_address}") if addresses.empty?
      addresses.first
    end

    def geocoding_url
      URI::HTTPS.build(
        host: 'geocoding.geo.census.gov',
        path: '/geocoder/locations/onelineaddress',
        query: {
          address: @search_address,
          benchmark: 2020,
          format: 'json'
        }.to_query
      ).to_s
    end

    def get_json(url)
      Rails.logger.debug("fetching: #{url.to_s}")
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = 'Boreas / 0.1 (alpha)'
      
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end
  end
end
