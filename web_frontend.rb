require 'sinatra/base'
require 'erb'

class Web < Sinatra::Base
  def self.start
    Thread.new do
      Web.run!
    end
  end
  class Cache
    attr_accessor :_state, :_inside, :_outside, :max_age
    private :_state=, :_inside=, :_outside=

    class Value
      attr_reader :value, :time
      def initialize(v, time = Time.now)
        @value, @time = v, time
      end
      def to_s
        value
      end
    end

    def initialize(max_age = (5 * 60))
      @_state, @_inside, @_outside = nil, nil, nil
      @max_age = max_age
    end

    def state
      expire(:state)
      self._state ||= Value.new(StateManager.state)
    end

    def inside
      expire(:inside)
      self._inside ||= Value.new(TempManager::InsideTemperature.get.value)
    end

    def outside
      expire(:outside)
      self._outside ||= Value.new(TempManager::OutsideTemperature.get.value)
    end

    def desired_state
      expire(:desired_state)
      self._desired_state ||= Value.new(TemperatureNeighborhood.nearest_mean_value([inside, outside]))
    end

    def expire(v, expire_value = nil)
      instance_variable_set(:"@_#{v}", expire_value)
    end

    private

    def expired?(v)
      return true if v.nil?
      (Time.now - max_age) > v.time
    end

    def expire(v, *dependents)
      var_name = :"@_#{v}"
      val = instance_variable_get(var_name)
      if expired?(val)
        [var_name].concat(dependents.map {|d| :"@_#{d}"}).each do |n|
          instance_variable_set(n, nil)
        end
      end
    end
  end

  set :cache, Cache.new

  set :static, true

  configure do
    EventBus.subscribe(:state_change, self, :expire_state)
  end

  get '/tm' do
    chart_data = TemperatureNeighborhood.chartable_points
    4.times { chart_data << [cache.inside.value, cache.outside.value, cache.state.value.to_s] }

    erb :index, locals: {state: cache.state.to_s, inside: cache.inside.to_s, outside: cache.outside.to_s,
      chart_data: chart_data, desired_state: cache.desired_state}
  end

  post '/tm/toggle' do
    change = if params[:to]
      EventBus.publish(:state_change, to: change)
      params[:to].intern
    else
      StateManager.toggle
    end

    EventBus.publish(:learn_from_now) unless params[:unusual]

    TempController.set(change)

    #erb :index, state: cache.state, inside: cache.insdie, outside: cache.outside
    redirect '/tm'
  end

  post '/tm/learn' do
    EventBus.publish(:learn_from_now) unless params[:unusual]

    redirect '/tm'
  end

  def expire_state(parms)
    cache.expire(:state, parms[:to])
  end

  protected

  def cache
    settings.cache
  end
end
