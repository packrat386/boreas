require "net/http"

module Boreas
  module RequestHelper
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
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      data = JSON.parse(get_url(url).body)
      t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)

      Rails.logger.debug("call to #{url} finished in #{t1 - t0} ms")

      data
    end

    def get_url(url)
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "Boreas / #{Boreas::VERSION}"

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      if res.code != "200"
        Rails.logger.debug("call to #{url} errored: #{res.code} -> #{res.body}")
        raise Boreas::Errors::APIError.new("call to API: #{url} got error code: #{res.code}")
      end

      res
    end
  end
end
