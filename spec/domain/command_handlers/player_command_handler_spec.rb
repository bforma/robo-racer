require "domain_helper"

describe PlayerCommandHandler, type: :command_handlers do
  let(:uuid) { new_uuid }
  let(:access_token) { new_uuid }

  describe CreatePlayerCommand do
    let(:command) do
      CreatePlayerCommand.new(
        id: uuid,
        name: "Bob",
        email: "bob@localhost.local",
        password: "secret",
        password_confirmation: "secret",
        access_token: access_token
      )
    end

    describe "validations" do
      it { should validate_presence_of :id }
      it { should validate_presence_of :name }
      it { should validate_presence_of :email }
      it { should validate_presence_of :password }
      it { should validate_presence_of :password_confirmation }
      it { should validate_presence_of :access_token }

      context "passwords" do
        subject { command }

        context "when equal" do
          it "are encrypted" do
            expect(subject).to be_valid
            expect(BCrypt::Password.new(subject.password)).to eq("secret")
            expect(BCrypt::Password.new(subject.password_confirmation)).to eq("secret")
          end
        end

        context "when unequal" do
          before { subject.password_confirmation.reverse! }

          it "are cleared" do
            expect(subject).to_not be_valid
            expect(subject.password).to be_nil
            expect(subject.password_confirmation).to be_nil
          end
        end
      end
    end

    describe "dispatch" do
      it_behaves_like "an event publisher" do
        let(:expected_events) do
          [PlayerCreatedEvent.new(
            uuid, "Bob", "bob@localhost.local", "secret", access_token
          )]
        end
      end
    end
  end
end
