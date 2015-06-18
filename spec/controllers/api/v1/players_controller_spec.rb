require "rails_helper"

describe Api::V1::PlayersController do
  let(:player) { login_player }

  describe "GET #show" do
    let(:request) { get :show, id: player._id }
    subject { request }

    it { expect(subject.status).to eq(200) }
    it do
      expect(subject.body).to be_json_eql(
        %({"id": "#{player.id}", "name": "#{player.name}"})
      )
    end

    context "when not found" do
      let(:request) { get :show, id: "unknown" }

      it { expect(subject.status).to eq(404) }
    end
  end

  describe "GET #me" do
    let(:request) { get :me }
    subject { request }

    it { expect(subject.status).to eq(200) }
    it do
      expect(subject.body).to be_json_eql(
        %({
            "id": "#{player.id}",
            "access_token": "#{player.access_token}",
            "email": "#{player.email}",
            "name": "#{player.name}"
        })
      )
    end
  end
end
