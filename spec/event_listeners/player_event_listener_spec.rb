require 'rails_helper'

describe PlayerEventListener do
  let(:listener) { PlayerEventListener.new }
  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  describe PlayerCreatedEvent do
    let(:event) { build(:player_created_event) }

    specify do
      expect { handle_event }.to change { Player.count }.by(1)
    end

    context "attributes" do
      before { handle_event }
      subject { Player.last }

      its(:id) { should eq(event.id) }
      its(:name) { should eq(event.name) }
      its(:email) { should eq(event.email) }
      its(:encrypted_password) { should eq(event.password) }
    end
  end
end
