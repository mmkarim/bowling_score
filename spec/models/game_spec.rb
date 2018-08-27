require "rails_helper"

describe Game do
  it "should assign score_info upon creation" do
    expect(Game.create!.score_info).not_to be_nil
  end
end
