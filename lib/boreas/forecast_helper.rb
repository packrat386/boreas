module Boreas
  module ForecastHelper
    def daily_forecast_title(dd)
      date = Time.parse(dd["startTime"]).strftime("%-m/%-d")

      "#{dd["name"]} (#{date}): #{dd["temperature"]}°F - #{dd["shortForecast"]} "
    end

    def hourly_forecast_table(hd)
      thead = content_tag(:thead) do
        content_tag(:tr) do
          ["hour", "temperature", "wind", "forecast"].collect { |h| content_tag(:th, h, class: "forecast_datapoint") }.join.html_safe
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
      content_tag(:td, Time.parse(row["startTime"]).strftime("%l%p"), class: "forecast_datapoint") +
        content_tag(:td, "#{row["temperature"]}°F", class: "forecast_datapoint") +
        content_tag(:td, "#{row["windSpeed"]} #{row["windDirection"]}", class: "forecast_datapoint") +
        content_tag(:td, row["shortForecast"], class: "forecast_datapoint")
    end

    def alert_body(row)
      content_tag(:div, class: "alert_details") do
        concat(content_tag(:p) do
          row["description"].split("\n\n").collect do |line|
            content_tag(:span) do
              line.split(" ").each do |l|
                concat(wrap_link_in_anchor(l))
                concat(" ")
              end
            end + tag(:br)
          end.join.html_safe
        end)

        concat(content_tag(:p, row["instruction"]))
      end
    end

    def wrap_link_in_anchor(word)
      if is_a_link?(word)
        content_tag(:a, word, href: word)
      else
        word
      end
    end

    def is_a_link?(word)
      # dumb but probably true
      word.starts_with?("https://")
    end
  end
end
