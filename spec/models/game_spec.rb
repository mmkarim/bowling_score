require "rails_helper"

describe Game do
  subject { Game }
  it { should be_valid }

  let!(:game){FactoryGirl.create :game}
end
