require 'singleton'
require 'net/http'
require 'uri'

class TempController
  include Singleton

  URL = URI("https://use1-wap.tplinkcloud.com/?token=#{Settings.session_token}"\
    "&appName=Kasa_iOS&termID=#{Settings.session_id}&ospf=iOS%2010.0.2&"\
    "appVer=1.3.3.380&netType=4G&locale=en_US")

  CHANGE_JSON = %Q|{
	"method": "passthrough",
	"params": {
		"requestData": "{\\"system\\":{\\"set_relay_state\\":{\\"state\\":DESIRED_STATE}}}",
		"deviceId": "#{Settings.device_id}"
	}
}|
  STATES = {on: '1', off: '0'}

  def self.set(change)
    instance.send(:"set_#{change}")
  end

  def self.init
    set(:off)
  end

  def set_on
    post(CHANGE_JSON.gsub('DESIRED_STATE', STATES[:on]))
  end

  def set_off
    post(CHANGE_JSON.gsub('DESIRED_STATE', STATES[:off]))
  end

  private

  def post(body)
    request = Net::HTTP::Post.new(URL)
    request.body = body
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(URL.hostname, 443, use_ssl: true) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      p response.body
      true
    else
      p response.class
      p response.body
      false
    end
  end
end
