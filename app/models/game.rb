class Game < ApplicationRecord
  before_create :assign_score_info

  private
  def assign_score_info
    frames = Hash.new

    frame_hash = {
      throw_1: nil,
      throw_2: nil,
      score: nil,
      is_strike: false,
      is_spare: false
    }

    (1..10).each{|i| frames[i] = frame_hash}

    self.score_info = {
      current_frame_no: 1,
      is_finished: false,
      result: 0,
      pending_calculation: [],
      frames: frames
    }
  end
end
