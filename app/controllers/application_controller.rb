class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  def execute(command)
    envelope = Fountain::Envelope.as_envelope(command)
    gateway.dispatch(envelope, command_callback)
  end

  def command_callback
    @command_callback ||= DefaultCommandCallback.new(Rails.logger)
  end

  def event_store
    @event_store ||= Fountain::EventStore::RedisEventStore.build
  end

  def event_listeners
    @event_listeners ||= [
      PlayerEventListener.new
    ]
  end

  def gateway
    @gateway ||= RoboRacer::Configuration.wire_up(event_store, event_listeners)
  end
end
