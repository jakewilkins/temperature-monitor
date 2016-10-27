require 'net/http'
require 'uri'

module ChangeNotifier
  URI = URI('https://api.prowlapp.com/publicapi/add')
  class << self
    def init
      EventBus.subscribe(:state_changed, self, :call)
    end

    def call(state)
      #application, event, description

      event, description = message_for(state[:to])
      post(event, description)
    end

    def post(event, description)
      u = URI.clone
      u.query = "apikey=#{Settings.prowl_api_key}&application=TempMon&"\
        "event=#{event}&description=#{::URI.escape(description)}"

      request = Net::HTTP::Post.new(u)

      response = Net::HTTP.start(u.host, 443, use_ssl: true) do |http|
        http.request request
      end

      case response
      when Net::HTTPSuccess
        puts response.body
        true
      else
        p response.class
        puts response.body rescue ''
        false
      end
    end

    def message_for(state)
      if state == :on
        ['Turned On', 'We turned on your air conditioner']
      else
        ['Turned Off', 'We turned off your air conditioner']
      end
    end
  end
end
