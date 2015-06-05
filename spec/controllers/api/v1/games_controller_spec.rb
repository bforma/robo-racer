require 'rails_helper'

describe Api::V1::GamesController do
  let!(:player) { login_player }

  describe 'Api::BaseController errors' do
    let(:response) { put :start, id: 'game' }

    context 'when aggregate is not found' do
      before do
        expect_any_instance_of(described_class).
          to receive(:dispatch_command!).
          and_raise(Fountain::Repository::AggregateNotFoundError.new(
            GameAggregate,
            'game'
          ))
      end
      it { expect(response.status).to eq(404) }
    end

    context 'when command fails' do
      before do
        expect_any_instance_of(described_class).
          to receive(:dispatch_command!).
          and_raise(DomainError)
      end

      it { expect(response.status).to eq(422) }
      it do
        expect(response.body).to be_json_eql(
          %({
            "errors": [{
              "code": "domain_error",
              "title": "Domain error"
            }]
          })
        )
      end
    end

    context 'when command is invalid' do
      let(:response) do
        put :program_robot, id: 'game', instruction_cards: [build(:instruction_card)]
      end

      it { expect(response.status).to eq(422) }
      it do
        expect(response.body).to be_json_eql(
          %({
            "errors": [{
              "code": "instruction_cards",
              "title": "is the wrong length (should be 5 characters)"
            }]
          })
        )
      end
    end
  end

  describe 'GET #events' do
    let(:response) { get :events, id: 1 }

    it { expect(response.status).to eq(404) }

    context 'given a game' do
      before do
        given_events(GameAggregate: [build(:game_created_event, id: 1)])
      end

      it { expect(response.status).to eq(200) }
      it do
        expect(response.body).to be_json_eql(
          %([{
            "payload_type": "GameCreatedEvent",
            "payload": {
              "id": 1,
              "host_id": "bob",
              "state": "lobbying"
            }
          }])
        )
      end
    end
  end

  shared_examples 'an accepted PUT request' do
    context 'when command succeeds' do
      before do
        expect_any_instance_of(described_class).
          to receive(:dispatch_command!).
          with(command)
      end

      it { expect(response.status).to eq(202) }
    end
  end

  describe 'PUT #join' do
    it_behaves_like 'an accepted PUT request' do
      let(:command) { JoinGameCommand.new(id: 'game', player_id: player._id) }
      let(:response) { put :join, id: 'game' }
    end
  end

  describe 'PUT #leave' do
    it_behaves_like 'an accepted PUT request' do
      let(:command) { LeaveGameCommand.new(id: 'game', player_id: player._id) }
      let(:response) { put :leave, id: 'game' }
    end
  end

  describe 'PUT #start' do
    it_behaves_like 'an accepted PUT request' do
      let(:command) { StartGameCommand.new(id: 'game', player_id: player._id) }
      let(:response) { put :start, id: 'game' }
    end
  end

  describe 'PUT #program_robot' do
    it_behaves_like 'an accepted PUT request' do
      let(:command) do
        ProgramRobotCommand.new(
          id: 'game',
          player_id: player._id,
          instruction_cards: build_list(:instruction_card, 1)
        )
      end
      let(:response) do
        put(
          :program_robot,
          id: 'game',
          instruction_cards: [attributes_for(:instruction_card)]
        )
      end
    end
  end
end
