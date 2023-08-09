module Boreas
  class ForecastController < ActionController::Base
    prepend_view_path "views"

    def index
      @address = params.permit(:address).fetch(:address, "")

      unless @address.blank?
        @forecast_data = forecast_service.forecast_data
        @alert_data = forecast_service.alert_data
      end
    rescue => e
      Rails.logger.error [e.message, *e.backtrace].join($/)
      @error = e.message
    end

    private

    def forecast_service
      @forecast_service ||= ForecastService.new(@address)
    end
  end
end
