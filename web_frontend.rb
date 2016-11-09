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

    private

    def expired?(v)
      return true if v.nil?
      (Time.now - max_age) > v.time
    end

    def expire(v)
      var_name = :"@_#{v}"
      val = instance_variable_get(var_name)
      instance_variable_set(var_name, nil) if expired?(val)
    end
  end

  set :cache, Cache.new

  set :static, true

  get '/tm' do
    chart_data = TemperatureNeighborhood.chartable_points
    4.times { chart_data << [cache.inside.value, cache.outside.value, cache.state.value.to_s] }

    erb :index, locals: {state: cache.state.to_s, inside: cache.inside.to_s, outside: cache.outside.to_s,
      chart_data: chart_data}
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

  protected

  def cache
    settings.cache
  end
end
