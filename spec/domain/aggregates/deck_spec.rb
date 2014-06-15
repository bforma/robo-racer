require 'domain_helper'

describe Deck do
  let(:drawable) { %w(1 2) }
  let(:drawn) { Array.new }
  let(:discarded) { Array.new }
  let(:deck) { Deck.new(drawable, drawn, discarded) }

  describe "#initialize" do
    subject { deck }

    its(:drawable) { should eq(%w(1 2)) }
    its(:drawn) { should be_empty }
    its(:discarded) { should be_empty }

    context "given discarded cards" do
      let(:drawable) { %w(2) }
      let(:drawn) { Array.new }
      let(:discarded) { %w(1) }

      its(:drawable) { should eq(%w(2)) }
      its(:drawn) { should be_empty }
      its(:discarded) { should eq(%w(1)) }
    end
  end

  describe "drawing and discarding cards" do
    subject { deck.draw_card }

    it("draws the top card") { is_expected.to eq("1") }
    
    context "when a card is drawn" do
      let!(:drawn_card) { deck.draw_card }
      
      it("draws the new top card") { is_expected.to eq("2") }
      
      context "and discarded" do
        before { deck.discard_card(drawn_card) }
        
        it("is not drawn until reshuffled") { is_expected.to_not eq(drawn_card) }

        context "when empty" do
          before do
            deck.draw_card
            expect_any_instance_of(Array).to receive(:shuffle!)
          end

          it("shuffles and draws the top card") { is_expected.to eq("1") }
        end
      end
    end

    context "when all cards are drawn and none discarded" do
      before do
        2.times { deck.draw_card }
      end

      it { expect { subject }.to raise_error(OutOfCardsError) }
    end
  end

  describe "#discard_card" do
    subject { deck.discard_card(card) }

    context "when card has not yet been drawn" do
      let(:card) { "1" }

      it { expect { subject }.to raise_error(CardNotYetDrawnError) }
    end

    context "when card is already discarded" do
      let!(:drawn_card) { deck.draw_card }
      before { deck.discard_card(drawn_card) }

      let(:card) { drawn_card }

      it { expect { subject }.to raise_error(CardAlreadyDiscardedError) }
    end

    context "when card is unknown to deck" do
      let(:card) { "unknown" }

      it { expect { subject }.to raise_error(UnknownCardError) }
    end
  end
end
