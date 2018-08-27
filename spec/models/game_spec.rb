require "rails_helper"

describe Game do
  subject { information }
  it { should be_valid }

  let!(:game){FactoryGirl.create :game}
end
