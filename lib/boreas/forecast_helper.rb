module Boreas
  module ForecastHelper
    def daily_forecast_title(dd)
      date = Time.zone.parse(dd['startTime']).strftime("%-m/%-d")

      "#{dd['name']} (#{date}): #{dd['shortForecast']}"
    end

    def hourly_forecast_table(hd)
      thead = content_tag(:thead) do
        content_tag(:tr) do
          ['hour', 'temperature', 'wind', 'forecast'].collect { |h| content_tag(:th, h) }.join.html_safe
        end
      end

      tbody = content_tag(:tbody) do
        hd.collect do |row|
          content_tag(:tr) do
            hourly_forecast_row(row)
          end
        end.join.html_safe
      end

      content_tag(:table, thead.concat(tbody))
    end
    
    def hourly_forecast_row(row)
      content_tag(:td, Time.zone.parse(row['startTime']).strftime("%l%p")) +
        content_tag(:td, "#{row['temperature']} F") +
        content_tag(:td, "#{row['windSpeed']} #{row['windDirection']}") +
        content_tag(:td, row['shortForecast'])
    end
  end
end
