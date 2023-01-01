require "action_controller/railtie"

module Boreas
  VERSION = "0.0.4"

  class Application < Rails::Application
    config.logger = Logger.new(Rails.env.test? ? nil : $stdout)
    Rails.logger = config.logger

    config.autoload_paths = ["#{Rails.root}/lib"]
    config.eager_load = true

    routes.append do
      scope module: "boreas" do
        get "forecast", action: :index, controller: "forecast"
      end
    end
  end
end

Rails.application.initialize!
