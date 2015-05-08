require 'gosu'

module ZOrder
  Background, Stars, Player, Projectile, UI = *0..4
end

# Main loop
class GameWindow < Gosu::Window
  def initialize
    # height, width, fullscreen
    super(1280, 960, false)
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new(self, "assets/space.jpg", true)

    @player = Player.new(self)
    @player.warp(640, 480)

    @star_anim = Gosu::Image::load_tiles(self, "assets/monster.png", 430, 385, false)

    @stars = Array.new
    @projectiles = Array.new

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @bg_music = Gosu::Song.new(self, "assets/zelda.mp3").play(true)
  end

  def update
    if button_down? Gosu::KbLeft then
      @player.turn_left
    end
    if button_down? Gosu::KbRight then
      @player.turn_right
    end
    if button_down? Gosu::KbUp  then
      @player.accelerate
    end
    @player.move
    @projectiles.each do |projectile| 
      projectile.move
      projectile.collect_stars(@stars)
    end

    if rand(100) < 4 and @stars.size < 25 then
      @stars.push(Star.new(@star_anim))
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
    @stars.each { |star| star.draw }
    @projectiles.each{ |projectile| projectile.draw }
    @font.draw("Score: #{$score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::KbSpace
      @projectiles.push(Projectile.new(self, @player.x, @player.y, @player.angle))
    end
  end
end

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

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 1280
    @y %= 960

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
  $score
  end
end

class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @x = rand * 1280
    @y = rand * 960
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Stars, 1, 1)
  end
end

class Projectile
  def initialize(window, playerx, playery, playerangle)
    @beep = Gosu::Sample.new(window, "assets/coin_sound.wav")
    @fire = Gosu::Sample.new(window, "assets/hadouken.mp3").play
    @image = Gosu::Image.new(window, ["assets/hadouken.png", "assets/hadouken-red.png"].sample)
    @x = playerx
    @y = playery
    @angle = playerangle
    @vel_x = 0
    @vel_y = 0

  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

   def move
    @x += @vel_x * 2
    @y += @vel_y * 2

    # @x %= 1280
    # @y %= 960
  end
  
  def draw
    @image.draw_rot(@x, @y, ZOrder::Projectile, @angle)
    self.accelerate

  end 

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 200 then
        $score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end

window = GameWindow.new
window.show