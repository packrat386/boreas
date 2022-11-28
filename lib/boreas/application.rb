require 'action_controller/railtie'

module Boreas
  class Application < Rails::Application
    config.logger = Logger.new($stdout)
    Rails.logger  = config.logger

    config.autoload_paths = ["#{Rails.root}/lib"]
    config.eager_load = true
  end
end

Rails.application.initialize!

Boreas::Application.routes.draw do
  scope module: 'boreas' do
    get 'forecast', action: :index, controller: 'forecast'
  end
end
