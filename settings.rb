
module Settings
  module_function

  def session_token
    ENV['SESSION_TOKEN']
  end

  def session_id
    ENV['SESSION_ID']
  end

  def device_id
    ENV['DEVICE_ID']
  end

  def darksky_key
    ENV['DARKSKY_KEY']
  end

  def lat_long
    ENV['LAT_LONG']
  end

  def particle_secret
    ENV['PARTICLE_SECRET']
  end

  def aws_button_id
    ENV['AWS_BUTTON_ID']
  end

  def particle_device_id
    ENV['PARTICLE_DEVICE_ID']
  end

  def prowl_api_key
    ENV['PROWL_API_KEY']
  end

  def kasa_user
    ENV['KASA_USER']
  end

  def kasa_password
    ENV['KASA_PASSWORD']
  end

  def kasa_uuid
    ENV['KASA_UUID']
  end

  def session_token=(str)
    ENV['SESSION_TOKEN'] = str
    begin
      str = File.read('/etc/temperature_monitor.conf')
      str.gusb(/^export SESSION_TOKEN=.*$/, "export SESSION_TOKEN=#{str}")
      File.write('/etc/temperature_monitor.conf', str)
    rescue Exception => boom
      puts "error persisting session token\n#{boom.message}"
      puts "whatever..."
    end
  end
end
