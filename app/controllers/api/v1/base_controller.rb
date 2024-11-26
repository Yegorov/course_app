class API::V1::BaseController < ApplicationController
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound do
      render json: { status: 404, error: "Not Found" }, status: 404
    end
  end
end
