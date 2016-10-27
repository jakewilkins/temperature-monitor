
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
end
