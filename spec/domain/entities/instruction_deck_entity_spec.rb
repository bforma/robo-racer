require "domain_helper"

describe InstructionDeckEntity, type: :entities do
  let(:deck) { InstructionDeckEntity.new(cards) }
  let(:entity) { deck }
  let(:cards) { %w(1 2) }
  let(:bob) { "bob" }

  let(:card_1_dealt) { InstructionCardDealt.new(id, "bob", "1") }
  let(:card_2_dealt) { InstructionCardDealt.new(id, "bob", "2") }
  let(:card_1_discarded) { InstructionCardDiscarded.new(id, "1") }

  describe "dealing and discarding cards" do
    subject { deck.deal_card(bob) }

    it "deals the top card" do
      expect_events(card_1_dealt)
    end

    context "when a card is dealt" do
      before { given_events(card_1_dealt) }

      it "deals the new top card" do
        expect_events(card_2_dealt)
      end

      context "and discarded" do
        before { given_events(card_1_discarded) }

        it "is not dealt until reshuffled" do
          expect_events(card_2_dealt)
        end

        context "when no more cards" do
          before { given_events(card_2_dealt) }

          it "shuffles and deals the top card" do
            expect_events(
              InstructionDeckShuffled.new(id, ["1"]),
              card_1_dealt
            )
          end
        end
      end
    end

    context "when all cards are dealt but none are discarded" do
      before { given_events(card_1_dealt, card_2_dealt) }

      specify { expect { subject }.to raise_error(OutOfCardsError) }
    end
  end

  describe "#discard_card" do
    subject { deck.discard_card(card) }
    let(:card) { "1" }

    context "when a card is dealt" do
      before { given_events(card_1_dealt) }

      it { expect_events(card_1_discarded) }
    end

    context "when card has not yet been dealt" do
      it { expect { subject }.to raise_error(CardNotYetDealtError) }
    end

    context "when card is already discarded" do
      before { given_events(card_1_dealt, card_1_discarded) }

      it { expect { subject }.to raise_error(CardAlreadyDiscardedError) }
    end

    context "when card is unknown to deck" do
      let(:card) { "unknown" }

      it { expect { subject }.to raise_error(UnknownCardError) }
    end
  end
end
