module AuthenticationHelper
  def login_player
    player_id = new_uuid
    given_events(
      PlayerAggregate: [
        build(:player_created_event, id: player_id)
      ]
    )
    login_as(Player.find(player_id), :scope => :player)
  end
end
