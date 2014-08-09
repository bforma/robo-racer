require 'rails_helper'

describe Api::V1::GamesController do
  let!(:player) { login_player }

  describe 'GET #events' do
    let(:request) { get :events, id: 1 }
    subject { request }

    context 'given a game' do
      before do
        given_events(GameAggregate: [build(:game_created_event, id: 1)])
      end

      it { expect(subject.status).to eq(200) }
      it do
        expect(subject.body).to be_json_eql(
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

    context 'given game not found' do
      it { expect(subject.status).to eq(404) }
    end
  end
end
