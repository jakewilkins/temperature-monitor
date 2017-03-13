module TplinkClient
  module_function

  TokenExpired = Class.new(RuntimeError)

  URL = "https://use1-wap.tplinkcloud.com/?token={SETTINGS_SESSION_TOKEN}"\
    "&appName=Kasa_iOS&termID={SETTINGS_SESSION_ID}&ospf=iOS%2010.0.2&"\
    "appVer=1.3.3.380&netType=4G&locale=en_US"

  def post(body)
    case (response = _post(authed_url, body))
    when Net::HTTPSuccess
      p response.body
      json = JSON.load(response.body)
      if json['error_code'] == -20651
        raise TokenExpired
      end
      true
    else
      p response.class
      p response.body
      false
    end
  rescue TokenExpired
    refresh_token
    retry
  end

  def authed_url
    URL.clone.gsub('{SETTINGS_SESSION_TOKEN}', Settings.session_token).gsub(
      '{SETTINGS_SESSION_ID}', Settings.session_id)
  end

  def refresh_token
    params = {
      'method' => 'login',
      'params' => {
        'appType' => 'Kasa_iOS',
        'cloudUserName' => Settings.kasa_user,
        'cloudPassword' => Settings.kasa_password,
        'terminalUUID'  => Settings.session_id
      }
    }
    p params
    response = _post('https://wap.tplinkcloud.com', JSON.dump(params))
    case response
    when Net::HTTPSuccess
      json = JSON.load(response.body)
      p json
      Settings.session_token = json['result']['token']
    else
      raise response
    end
  end

  def _post(url, body)
    uurl = URI(url)
    request = Net::HTTP::Post.new(uurl)
    request.body = body
    request['Content-Type'] = 'application/json'

    Net::HTTP.start(uurl.hostname, 443, use_ssl: true) do |http|
      http.request(request)
    end
  end

end
