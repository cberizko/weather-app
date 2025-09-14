require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  describe "GET /forecast/new" do
    it "renders the new page" do
      get new_forecast_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to include("Weather App")
    end
  end

  describe "POST /forecast" do
    it "redirects to the forecast show page with city and zip params" do
      post forecast_path, params: { zip: "12345" }
      expect(response).to redirect_to(forecast_path(zip: "12345"))
    end
  end

  describe "GET /forecast" do
    let(:city) { "Test City" }
    let(:zip) { "12345" }
    let(:data) { {
      "location" => {
        "name" => city
      },
      "current" => {
        "temp_c" => 16.0,
        "temp_f" => 70.0
      },
      "forecast" => {
        "forecastday" => [
          {
            "date" => "2025-01-01",
            "day" => {
              "maxtemp_f" => 80.0,
              "maxtemp_c" => 17.0,
              "mintemp_f" => 50.0,
              "mintemp_c" => 10.0,
              "condition" => {
                "text" => "Cloudy"
              }
            }
          }
        ]
      }
    }}

    context "when WeatherClient succeeds" do
      after do
        Rails.cache.clear
      end

      it "returns a successful response" do
        allow_any_instance_of(WeatherClient).to receive(:forecast_by_zip_code).and_return(data)
        get forecast_path, params: { zip: zip, city: city }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(city)
      end

      it "fetches from cache if available" do
        expect_any_instance_of(WeatherClient).not_to receive(:forecast_by_zip_code)
        Rails.cache.write([ "forecasts", zip ], data)
        get forecast_path, params: { zip: zip, city: city }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(city)
      end
    end

    context "when WeatherClient raises WeatherError" do
      before do
        allow_any_instance_of(WeatherClient).to receive(:forecast_by_zip_code).and_raise(WeatherClient::WeatherError, "Weather Service is Currently Down")
      end

      it "redirects to the new forecast page with flash alert" do
        get forecast_path, params: { zip: zip, city: city }
        expect(response).to redirect_to(new_forecast_path)
        follow_redirect!
        expect(response.body).to include("Weather Service is Currently Down")
      end
    end
  end
end
