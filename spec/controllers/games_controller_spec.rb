require 'rails_helper'

describe GamesController do
  before { login_player }

  describe 'POST #create' do
    subject { post :create }
    before do
      expect_any_instance_of(described_class).
        to receive(:new_uuid).
        and_return(1)
    end

    it { is_expected.to redirect_to(game_path(1)) }
  end

  describe 'GET #show' do
    subject { get :show, id: 1 }
    render_views

    it { is_expected.to render_template(:show) }
    it { is_expected.to render_template('layouts/game') }
  end
end
