module Boreas
  class ForecastController < ActionController::Base
    prepend_view_path "views"

    def index
      @address = params.permit(:address).fetch(:address, "")
      @forecast_data = ForecastService.new(@address).forecast_data unless @address.blank?
    rescue => e
      Rails.logger.error [e.message, *e.backtrace].join($/)
      @error = e.message
    end
  end
end
