class Procline
  attr_reader :last_status, :time_waiting

  def initialize
    @last_status, @time_waiting = "", ""
  end

  def tick(count)
    set(@last_status, "Waiting #{time_left(count)}.")
  end

  def begin_run
    set("beginnning temp check...")
  end

  def complete_run
    @last_status = "Prev. Success: #{Time.now.strftime('%m/%d %H:%M')}."
  end

  def error_run
    @last_status = "Prev. Failure: #{Time.now.strftime('%m/%d %H:%M')}."
  end

  private

  def set(str, opt = "")
    Process.setproctitle("temperature_monitor: #{str} #{opt}")
  end

  def time_left(num)
    five_minutes = 5 * 60
    left = five_minutes - num
    mins = left / 60

    "#{mins} Min"
  end
end

