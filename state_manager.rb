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

  def self.current
    instance.state
  end

  def self.locked?
    instance.locked?
  end

  def self.lock!
    instance.lock!
  end

  def self.unlock!
    instance.unlock!
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

  def locked?
    @locked_until > Time.now
  end

  def lock!
    @locked_until = begin
      t = Time.now
      t += ((24 - t.hour) * 60 * 60)
      t -= t.min * 60
      t -= t.sec
    end
  end

  def unlock!
    @locked_until = Time.now - 1
  end

  def changed(args)
    @state = args[:to]
  end
end
