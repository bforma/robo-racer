class GamesController < ApplicationController
  before_action :authenticate_player!

  def create
    game_id = new_uuid
    dispatch_command!(CreateGameCommand.new(id: game_id, player_id: current_player.id))
    redirect_to action: :show, id: game_id
  end

  def show
    render :show, layout: "game"
  end
end
