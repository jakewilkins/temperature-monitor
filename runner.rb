require 'singleton'

class Runner
  include Singleton

  def self.init
    instance
  end

  def initialize
    EventBus.subscribe(:toggle_requested, self, :toggle_requested)
    EventBus.subscribe(:tick, self, :tick)
  end

  def tick(args)
    return if StateManager.locked?
    return unless (change = TempManager.check)

    unless StateManager.state == change
      EventBus.publish(:state_changed, to: change)
      TempController.set(change)
    end
  end

  def toggle_requested(args)
    to = StateManager.toggle

    TempController.set(to)
  end
end
