require 'singleton'
require 'net/http'
require 'uri'

class TempController
  include Singleton

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
    TplinkClient.post(CHANGE_JSON.gsub('DESIRED_STATE', STATES[:on]))
  end

  def set_off
    TplinkClient.post(CHANGE_JSON.gsub('DESIRED_STATE', STATES[:off]))
  end

  private

end
