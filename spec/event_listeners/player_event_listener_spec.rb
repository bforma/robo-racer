require "rails_helper"

describe PlayerEventListener do
  let(:listener) { PlayerEventListener.new }
  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  describe PlayerCreatedEvent do
    let(:event) { build(:player_created_event) }

    specify { expect { handle_event }.to change { Player.count }.by(1) }

    context "attributes" do
      before { handle_event }
      subject { Player.last }

      its(:id) { should eq(event.id) }
      its(:name) { should eq(event.name) }
      its(:email) { should eq(event.email) }
      its(:encrypted_password) { should eq(event.password) }
      its(:access_token) { should eq(event.access_token) }
    end
  end
end
