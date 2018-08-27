class Game::UpdateScore
  attr_accessor :game, :score_info, :value

  def initialize(game, value)
    @game = game
    @score_info = @game.score_info.with_indifferent_access
    @value = value
  end

  def update
    error_msg = check_error
    return [false, error_msg] if error_msg

    add_score
    calculate_pending_score

    @game.score_info = @score_info
    if @game.save
      [true, @game]
    else
      [false, @game.errors.full_messages.first]
    end
  end

  private

  def check_error
    return "Game already finished!" if @score_info[:is_finished]
    return "Invalid score value!" unless (0..10).include?(@value)
  end


  def add_score
    frame_no = @score_info[:current_frame_no]
    current_frame = @score_info[:frames][frame_no.to_s]

    if current_frame[:throw_1].nil?
      add_value_to_throw_1 frame_no, current_frame

    elsif current_frame[:throw_2].nil?
      return if (current_frame[:throw_1] + @value > 10) && (frame_no < 10)
      add_value_to_throw_2 frame_no, current_frame

    elsif frame_no == 10 && (current_frame[:is_spare] || current_frame[:is_strike])
      current_frame[:bonus] = @value
      @score_info[:pending_calculation] << frame_no
    end
  end

  def add_value_to_throw_1 frame_no, current_frame
    current_frame[:throw_1] = @value
    current_frame[:is_strike] = true if @value == 10

    if current_frame[:is_strike] && frame_no < 10
      @score_info[:current_frame_no] = frame_no + 1
      @score_info[:pending_calculation] << frame_no
    end
  end

  def add_value_to_throw_2 frame_no, current_frame
    current_frame[:throw_2] = @value
    current_frame[:is_spare] = true if (current_frame[:throw_1] + current_frame[:throw_2] == 10) && !current_frame[:is_strike]


    if frame_no < 10
      @score_info[:current_frame_no] = frame_no + 1
      @score_info[:pending_calculation] << frame_no
    elsif frame_no == 10 && !current_frame[:is_spare] && !current_frame[:is_strike]
      @score_info[:pending_calculation] << frame_no
    end
  end

  def calculate_pending_score
    while(!@score_info[:pending_calculation].empty?)
      frame_no = @score_info[:pending_calculation].shift
      current_frame = @score_info[:frames]["#{frame_no}"]

      score = if current_frame[:is_strike]
        calculate_strike frame_no
      elsif current_frame[:is_spare]
        calculate_spare frame_no
      else
        current_frame[:throw_1] + current_frame[:throw_2]
      end

      if score
        add_score_to_frame current_frame, frame_no, score
      else
        @score_info[:pending_calculation].unshift frame_no
        break
      end

    end
  end

  def calculate_strike frame_no
    if frame_no < 10
      next_throw_1 =  @score_info[:frames]["#{frame_no+1}"][:throw_1]
      if next_throw_1
        next_throw_2 = if next_throw_1 == 10
          frame_no + 1 == 10 ? @score_info[:frames]["#{frame_no+1}"][:throw_2] : @score_info[:frames]["#{frame_no+2}"][:throw_1]
        else
          @score_info[:frames]["#{frame_no+1}"][:throw_2]
        end
        next_throw_1 + next_throw_2 + 10 if next_throw_2
      end
    elsif frame_no == 10
      throw_2 =  @score_info[:frames]["#{frame_no}"][:throw_2]
      bonus = @score_info[:frames]["#{frame_no}"][:bonus]
      if throw_2 && bonus
        throw_2 + bonus + 10
      end
    end
  end

  def calculate_spare frame_no
    next_throw = if frame_no == 10
      @score_info[:frames]["#{frame_no}"][:bonus]
    else
      @score_info[:frames]["#{frame_no+1}"][:throw_1]
    end
    next_throw + 10 if next_throw
  end

  def add_score_to_frame current_frame, frame_no, score
    prev_frame = @score_info[:frames]["#{frame_no-1}"]
    prev_score = prev_frame ? prev_frame[:score] : 0

    current_frame[:score] = prev_score + score
    @score_info[:result] = current_frame[:score]

    if frame_no == 10
      @score_info[:is_finished] = true
    end
  end
end
