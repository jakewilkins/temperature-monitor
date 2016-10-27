#require_relative 'setup'
require_relative 'procline'
require 'logger'
require 'event_bus'

class Poller
  attr_reader :procline, :logger, :button_monitor

  def self.go
    [Runner, ChangeNotifier, StateManager, TempController,
     TemperatureNeighborhood].each(&:init)
    #Runner.init # subscribes to EventBus
    #ChangeNotifier.init
    #StateManager.init # TODO: read this off of switch
    #TempController.set(:off) # just so we know
    new.go
  end

  def initialize
    @procline = Procline.new
    @logger = Logger.new("poller.log")
    logger.level = Logger::WARN
    @button_monitor = ButtonMonitor.new
  end

  def go
    button_monitor.start

    @quit = false
    trap('INT') { @quit = true}
    five_minutes = 5 * 60
    tick = 0

    run # run on start
    loop do
      break if @quit
      if tick > five_minutes
        tick = 0
        run
      else
        button_monitor.join if button_monitor.dead?
        tick += 1
        procline.tick(tick)
        sleep 1
      end
    end
    logger.fatal "byeeeeeeee!!!"
  end

  def run
    begin
      logger.debug 'beginning temperature check...'
      procline.begin_run
      EventBus.publish(:tick)
      procline.complete_run
      logger.info " temperature monitored "
    rescue Exception => boom
      procline.error_run
      logger.error "got a #{boom.message}:\n#{boom.backtrace.join("\n")}"
    end
  end
end
