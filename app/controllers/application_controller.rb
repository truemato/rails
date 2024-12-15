class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    render json: {message: 'ERROR'}, status: :unprocessable_entity
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {message: 'ERROR'}, status: :unprocessable_entity
  end
end
