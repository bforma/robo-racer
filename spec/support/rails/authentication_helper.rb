module AuthenticationHelper

  def do_login_player
    player_id = new_uuid
    given_events(
      PlayerAggregate: [
        build(:player_created_event, id: player_id)
      ]
    )

    player = Player.find(player_id)
    yield(player)
    player
  end

  module Feature
    def login_player
      do_login_player { |player| login_as(player, :scope => :player) }
    end
  end

  module Controller
    def login_player
      do_login_player { |player| sign_in(:player, player) }
    end
  end
end
