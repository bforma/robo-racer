require 'rails_helper'

describe GamesController do
  before { login_player }

  describe 'POST #create' do
    before do
      expect_any_instance_of(described_class).
        to receive(:new_uuid).
        and_return(1)
    end
    it { expect(post(:create)).to redirect_to(game_path(1)) }
  end
end
