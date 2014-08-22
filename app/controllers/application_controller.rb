class ApplicationController < ActionController::Base
  extend Memoist

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  def new_uuid
    SecureRandom.uuid
  end

  def dispatch_command(command)
    gateway.dispatch(command)
  end

  def dispatch_command!(command)
    gateway.dispatch!(command)
  end

  def gateway
    @gateway ||= GatewayBuilder.build
  end
end
