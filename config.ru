require_relative 'web_frontend.rb'
require 'event_bus'
require_relative 'settings'
require_relative 'temp_manager'
require_relative 'temperature_neighborhood'
require_relative 'state_manager'

TemperatureNeighborhood.init
StateManager.init

run Web.new
