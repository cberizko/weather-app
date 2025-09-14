class WeatherClient
  API_BASE = ENV.fetch("WEATHER_API_URL", "http://api.weatherapi.com/v1/")
  def initialize()
    # Loading my api key here just for easier dev testing
    @api_key = ENV.fetch("WEATHER_API_KEY", "dff5427e11c84a47a61224911251109")
  end

  def forecast_by_zip_code(zip_code)
    response = HTTParty.get(API_BASE + "forecast.json?key=#{@api_key}&q=#{zip_code}&days=5")
    raise WeatherError, "Weather Service is Currently Down" if response.code == 500
    raise WeatherError, "Invalid Zip/Postal Code Provided" if response["error"] && response["error"]["code"] == 1006
    return JSON.parse(response.body)
  end

  class WeatherError < StandardError; end
end
