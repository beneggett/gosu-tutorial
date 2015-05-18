
class Player
  attr_reader :x, :y, :angle
  # Initializes the player object, takes a window where the image should be drawn
  def initialize(window)
    @image = Gosu::Image.new(window, "assets/mario.png", false)
    @beep = Gosu::Sample.new(window, "assets/coin_sound.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    $score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end
  
  def decelerate
    @vel_x -= Gosu::offset_x( @angle, 0.5)
    @vel_y -= Gosu::offset_y( @angle, 0.5)
  end  

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 1280
    @y %= 960

    @vel_x *= 0.99
    @vel_y *= 0.99
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
  $score
  end
end