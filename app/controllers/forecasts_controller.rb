class ForecastsController < ApplicationController
  def new
  end

  def create
    redirect_to forecast_path(zip: params[:zip])
  end

  def show
    @city = params[:city]
    @cached = true
    begin
      @forecast = Rails.cache.fetch([ "forecasts", params[:zip] ], expires_in: 30.minutes) do
        @cached = false
        WeatherClient.new.forecast_by_zip_code(params[:zip])
      end
    rescue WeatherClient::WeatherError => e
      flash[:alert] = e.message
      redirect_to new_forecast_path
    end
  end
end
