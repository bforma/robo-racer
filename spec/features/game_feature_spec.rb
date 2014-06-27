require 'rails_helper'

describe GamesController do
  before { login_player }

  it "creates a new game" do
    visit root_path

    click_on I18n.t("home.index.new_game")

    expect(page).to have_content "It's a game!"
  end
end
