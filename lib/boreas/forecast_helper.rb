module Boreas
  module ForecastHelper
    def format_forecast(forecast_data)
      forecast_data.map do |row|
        {
          time: Time.zone.parse(row['startTime']).strftime("%F %H:%M"),
          temperature: "#{row["temperature"]} #{row["temperatureUnit"]}",
          wind: "#{row["windSpeed"]} #{row["windDirection"]}",
          forecast: row['shortForecast']
        }
      end
    end
  end
end
