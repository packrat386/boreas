module Boreas
  class GeocodingService
    Point = Struct.new(:latitude, :longitude, keyword_init: true) do
      def to_s
        "#{latitude},#{longitude}"
      end
    end

    def initialize(address)
      @search_address = address
    end

    def point
      if ZipcodeLookup.supports?(@search_address)
        ZipcodeLookup.fetch_point(@search_address)
      elsif CensusLookup.supports?(@search_address)
        CensusLookup.fetch_point(@search_address)
      else
        raise NoMatchingAddressError.new("no lookup supported for address: #{address}")
      end
    end

    class ZipcodeLookup
      ZIP_DATA_PATH = "config/zipcodes.json"
      ZIP_DATA = JSON.parse(File.read(Rails.root.join(ZIP_DATA_PATH)))

      def self.supports?(address)
        /^[[:digit:]]{5}$/.match?(address)
      end

      def self.fetch_point(address)
        raise Boreas::Errors::NoMatchingAddressError.new("no coordinates found matching zip code: #{address}") unless ZIP_DATA["zipcodes"][address]

        Point.new(
          latitude: ZIP_DATA["zipcodes"][address]["lat"],
          longitude: ZIP_DATA["zipcodes"][address]["long"]
        )
      end
    end

    class CensusLookup
      extend RequestHelper

      def self.supports?(address)
        true
      end

      def self.fetch_point(address)
        addresses = get_json_cached(geocoding_url(address), 1.day).dig("result", "addressMatches")

        raise Boreas::Errors::NoMatchingAddressError.new("no coordinates found matching address: #{address}") if addresses.blank?
        matched_address = addresses.first

        Point.new(
          latitude: matched_address.dig("coordinates", "y").round(4),
          longitude: matched_address.dig("coordinates", "x").round(4)
        )
      end

      def self.geocoding_url(address)
        URI::HTTPS.build(
          host: "geocoding.geo.census.gov",
          path: "/geocoder/locations/onelineaddress",
          query: {
            address: address,
            benchmark: 2020,
            format: "json"
          }.to_query
        ).to_s
      end
    end
  end
end
