class PlayCurrentRoundJob
  include Sidekiq::Worker

  sidekiq_options queue: :games, backtrace: true

  def perform(game_id)
    gateway = RoboRacer::Gateway.build
    gateway.dispatch(PlayCurrentRoundCommand.new(id: game_id))
  end
end
