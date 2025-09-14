require "rails_helper"

RSpec.describe WeatherClient do
  describe "#forecast_by_zip_code" do
    let(:zip) { "92101" }
    let(:weather_client) { described_class.new }

    context "when the API call succeeds" do
      let(:httparty_response) {
        double("HTTParty::Response",
                             code: 200,
                             body: {
                               location: { name: "A City" }
                             }.to_json)
      }

      before do
        allow(httparty_response).to receive(:[]).with("error").and_return(nil)
        allow(HTTParty).to receive(:get).and_return(httparty_response)
      end

      it "returns the parsed forecast data" do
        forecast = weather_client.forecast_by_zip_code(zip)
        expect(forecast).to eq({"location" => {"name" => "A City"}})
      end
    end

    context "when the API call returns a 500" do
      let(:httparty_response) {
        double("HTTParty::Response", code: 500)
      }
      before do
        allow(HTTParty).to receive(:get).and_return(httparty_response)
      end

      it "raises a WeatherError" do
        expect { weather_client.forecast_by_zip_code(zip) }.to raise_error(WeatherClient::WeatherError, "Weather Service is Currently Down")
      end
    end

    context "when the API call can not find the location" do
      let(:httparty_response) {
        double("HTTParty::Response",
                             code: 200,
                             body: {
                               error: { code: 1006 }
                             }.to_json)
      }
      before do
        allow(httparty_response).to receive(:[]).with("error").and_return({"code" => 1006})
        allow(HTTParty).to receive(:get).and_return(httparty_response)
      end

      it "raises a WeatherError" do
        expect { weather_client.forecast_by_zip_code(zip) }.to raise_error(WeatherClient::WeatherError, "Invalid Zip/Postal Code Provided")
      end
    end
  end
end