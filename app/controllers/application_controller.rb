class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  def new_uuid
    SecureRandom.uuid
  end

  def execute(command)
    gateway.dispatch(command)
  end

  def gateway
    @gateway ||= RoboRacer::Gateway.build
  end
end
