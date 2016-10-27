require 'singleton'

class StateManager
  include Singleton

  attr_reader :state

  def self.toggle
    instance.toggle
  end

  def self.state
    instance.state
  end

  def self.init
    instance
  end

  def initialize
    @state = :off

    EventBus.subscribe(:state_changed, self, :changed)
  end

  def toggle
    @state = state == :on ? :off : :on
  end

  def changed(args)
    @state = args[:to]
  end
end
