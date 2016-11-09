require 'singleton'
require 'uri'
require 'json'

class TempManager
  include Singleton

  class StateChange
    attr_reader :to, :time

    def initialize(to)
      @time, @to = Time.now, to
    end
  end

  def self.check
    instance.check
  end

  attr_reader :past_states, :current_state

  def initialize
    @past_states = []
    @current_state = false
  end

  def check
    outside = OutsideTemperature.get
    inside = InsideTemperature.get

    desired_state = TemperatureNeighborhood.nearest_mean_value([inside.value, outside.value])

    unless current_state == desired_state
      past_states << StateChange.new(desired_state)
      @current_state = desired_state
      return desired_state
    end
    false
  end

  class OutsideTemperature
    KEY = Settings.darksky_key
    URI = URI("https://api.darksky.net/forecast/#{KEY}/#{Settings.lat_long}"\
              "?exclude=minutely,daily,flags")

    def self.get
      resp = Net::HTTP.get_response(URI)

      case resp
      when Net::HTTPSuccess
        new(JSON.load(resp.body))
      else
        new(:unavailable)
      end
    end

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def value
      @value ||= data['currently']['temperature'].round(2)
    end
  end

  class InsideTemperature
    URI = URI("https://api.particle.io/v1/devices/#{Settings.particle_device_id}"\
             "/roomtempF?access_token=#{Settings.particle_secret}&format=raw")
    def self.get
      resp = Net::HTTP.get_response(URI)

      case resp
      when Net::HTTPSuccess
        new(resp.body.to_f)
      else
        new(:unavailable)
      end
    end

    attr_reader :value
    def initialize(val)
      @value = val
    end

    def gte(var)
      return false if value == :unavailable
      value.round(2) >= var
    end
  end
end
