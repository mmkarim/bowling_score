require "rails_helper"

describe "UpdateScore" do
  let!(:game){FactoryGirl.create :game}

  describe "#update" do
    context "return object" do
      it "should be an array with first element true and second elemnt game object if success" do
        score = 5
        succeed, result_hash = Game::UpdateScore.new(game, score).update
        expect(succeed).to eq(true)
        expect(result_hash).to eq(game.reload)
      end

      it "should be an array with first element false and second elemnt error string if failed" do
        score = 15
        succeed, error_msg = Game::UpdateScore.new(game, score).update
        expect(succeed).to eq(false)
        expect(error_msg).to eq("Invalid score value!")
      end
    end

    context "adding score behaviour" do
      it "should update score to throw_1 first" do
        score = 5
        _, result_hash = Game::UpdateScore.new(game, score).update
        expect(result_hash["score_info"]["frames"]["1"]["throw_1"]).to eq(score)
      end

      it "should update score to throw_2 second if throw_1 not strike" do
        Game::UpdateScore.new(game, 3).update
        score = 5
        _, result_hash = Game::UpdateScore.new(game, score).update
        expect(result_hash["score_info"]["frames"]["1"]["throw_2"]).to eq(score)
      end

      it "should update score to throw_1 of next frame if throw_1 of prev frame is strike" do
        Game::UpdateScore.new(game, 10).update
        score = 5
        _, result_hash = Game::UpdateScore.new(game, score).update
        expect(result_hash["score_info"]["frames"]["1"]["throw_2"]).to eq(nil)
        expect(result_hash["score_info"]["frames"]["2"]["throw_1"]).to eq(score)
      end

      it "should update is_strike = true if throw_1 is strike of the frame" do
        _, result_hash = Game::UpdateScore.new(game, 10).update
        expect(result_hash["score_info"]["frames"]["1"]["is_strike"]).to eq(true)
      end

      it "should update is_spare = true if summation of throw_1 and throw_2 is 10" do
        Game::UpdateScore.new(game, 4).update
        _, result_hash = Game::UpdateScore.new(game, 6).update
        expect(result_hash["score_info"]["frames"]["1"]["is_spare"]).to eq(true)
      end

      it "should increase current_frame_no after throw_1 and throw_2 finished with no strike" do
        Game::UpdateScore.new(game, 4).update
        _, result_hash = Game::UpdateScore.new(game, 6).update
        expect(result_hash["score_info"]["current_frame_no"]).to eq(2)
      end

      it "should increase current_frame_no after throw_1 finished with strike" do
        _, result_hash = Game::UpdateScore.new(game, 10).update
        expect(result_hash["score_info"]["current_frame_no"]).to eq(2)
      end
    end

    context "adding score for 10th frame" do
      before{(1..9).each{Game::UpdateScore.new(game, 10).update}}

      it "should let user update score 2 more times if throw_1 is a strike" do
        Game::UpdateScore.new(game, 10).update
        Game::UpdateScore.new(game, 9).update
        succeed, result_hash = Game::UpdateScore.new(game, 1).update
        expect(succeed).to eq(true)
      end

      it "should let user update score 1 more time after throw_1 and throw_2 if spare" do
        Game::UpdateScore.new(game, 1).update
        Game::UpdateScore.new(game, 9).update
        succeed, result_hash = Game::UpdateScore.new(game, 5).update
        expect(succeed).to eq(true)
      end

      it "should not let user update score after throw_1 and throw_2 if not spare or strike" do
        Game::UpdateScore.new(game.reload, 1).update
        Game::UpdateScore.new(game.reload, 4).update
        succeed, result_hash = Game::UpdateScore.new(game.reload, 5).update
        expect(succeed).to eq(false)
      end
    end

    context "calculating result scenario" do
      it "should add frame no to pending_calculation array upon completion of the frame" do
        Game::UpdateScore.new(game, 4).update
        _, result_hash = Game::UpdateScore.new(game, 6).update
        expect(result_hash["score_info"]["pending_calculation"]).to include(1)
      end

      it "should add 10 plus score of next throw_1 if spare" do
        Game::UpdateScore.new(game, 4).update
        Game::UpdateScore.new(game, 6).update
        _, result_hash = Game::UpdateScore.new(game, 5).update
        expect(result_hash["score_info"]["frames"]["1"]["score"]).to eq(15)
      end

      it "should add 10 plus score of next 2 throws if strike" do
        Game::UpdateScore.new(game, 10).update
        Game::UpdateScore.new(game, 6).update
        _, result_hash = Game::UpdateScore.new(game, 4).update
        expect(result_hash["score_info"]["frames"]["1"]["score"]).to eq(20)
      end

      it "should update result after completing calculation of each frame" do
        Game::UpdateScore.new(game, 4).update
        Game::UpdateScore.new(game, 6).update
        _, result_hash = Game::UpdateScore.new(game, 5).update
        expect(result_hash["score_info"]["frames"]["1"]["score"]).to eq(15)
      end
    end
  end
end
