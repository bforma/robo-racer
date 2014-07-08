class PlayCurrentRoundJob
  include Sidekiq::Worker

  sidekiq_options queue: :games, backtrace: true

  def perform(game_id)
    gateway = GatewayBuilder.build
    gateway.dispatch(PlayCurrentRoundCommand.new(id: game_id))
  end
end
