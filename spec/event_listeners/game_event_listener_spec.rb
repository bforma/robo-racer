require 'rails_helper'

describe GameEventListener do
  let(:listener) { GameEventListener.new }

  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  describe GameCreatedEvent do
    let(:event) { build(:game_created_event) }

    specify do
      expect { handle_event }.to change { Game.count }.by(1)
    end
  end

  describe PlayerJoinedGameEvent do
    let(:game_id) { new_uuid }
    let(:event) { build(:player_joined_game_event, id: game_id) }
    let(:game) { create(:game, _id: game_id) }

    specify do
      expect { handle_event }.
        to change { game.reload.player_ids }.
        from([]).
        to([event.player_id])
    end
  end

  describe PlayerLeftGameEvent do
    let(:game_id) { new_uuid }
    let(:joined_player_id) { new_uuid }
    let(:event) do
      build(:player_left_game_event, id: game_id, player_id: joined_player_id)
    end
    let(:game) { create(:game, _id: game_id, player_ids: [joined_player_id]) }

    specify do
      expect { handle_event }.
        to change { game.reload.player_ids }.
        from(game.player_ids).
        to([])
    end
  end
end
