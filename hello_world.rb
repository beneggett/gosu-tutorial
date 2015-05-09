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
    @bg_music = Gosu::Song.new(self, "assets/zelda.mp3")
    @bg_music.play(true)
    $timer = 0

    $specials = 5
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
    if button_down? Gosu::KbDown  then
      @player.decelerate
    end    
    @player.move
    @projectiles.each do |projectile| 
      projectile.move
      @projectiles.delete projectile if projectile.special && (projectile.start_timer + 250) < $timer
      projectile.collect_stars(@stars, @projectiles)
    end
    $timer += 1
    $level = ($timer / 100.to_i)
    if $timer % 1000 == 0
      $specials += 1 
    end

    case 
    when $level < 5
      size = 3
    when $level < 10
      size = 5
    when $level < 20
      size = 10      
    when $level < 30
      size = 20   
    when $level < 40
      size = 40   
    when $level < 50
      size = 60
    when $level < 60
      size = 100
    else
      size = rand(100..10000)
    end  
    if rand(100) < 4 and @stars.size < size then
      @stars.push(Star.new(@star_anim, self, @player))
    end

    if $score < 0 
      $score = 0
      Gosu::Sample.new(self, "assets/death.mp3").play
      sleep 2
      self.close
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
    @stars.each { |star| star.draw }
    @projectiles.each{ |projectile| projectile.draw }
    @font.draw("Score: #{$score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Level: #{$level}", 800, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Specials: #{$specials}", 800, 40, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::KbSpace
      @projectiles.push(Projectile.new(self, @player.x, @player.y, @player.angle))
    elsif id == Gosu::KbReturn
      if $specials >= 1
        @projectiles.push(Projectile.new(self, @player.x, @player.y, @player.angle, true)) 
        $specials -= 1
      end
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
  
  def decelerate
    @vel_x += Gosu::offset_x(- @angle, 0.5)
    @vel_y += Gosu::offset_y(- @angle, 0.5)
  end  

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 1280
    @y %= 960

    @vel_x *= 0.995
    @vel_y *= 0.995
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
  $score
  end
end

class Star
  attr_reader :x, :y, :window, :player

  def initialize(animation, window, player)
    @animation = animation
    @x = rand * 1280
    @y = rand * 960
    @player = player
    @window = window
    
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Stars, 1, 1)
    attack_player
  end


  def attack_player
    if Gosu::distance(@x, @y, @player.x, @player.y) < 200 && $timer % 5 == 0 then
      dmg = 1
      case 
      when $timer < 200
        dmg +=1
      when $timer < 500
        dmg +=2
      when $timer < 1000
        dmg +=3
      when $timer < 2000
        dmg +=4
      when $timer < 3000
        dmg +=8
      when $timer < 5000
        dmg +=15
      else
        dmg += 100
      end        
      $score -= dmg
      @punch = Gosu::Sample.new(window, "assets/punch.mp3").play
      true
    else
      false
    end
  end

end

class Projectile
  attr_accessor :start_timer, :special
  def initialize(window, playerx, playery, playerangle, special = false)
    @beep = Gosu::Sample.new(window, "assets/coin_sound.wav")
    @fire = Gosu::Sample.new(window, "assets/hadouken.mp3").play
    @image = Gosu::Image.new(window, ["assets/hadouken.png", "assets/hadouken-red.png"].sample)
    @image = Gosu::Image.new(window, "assets/coin.jpeg") if @special
    @x = playerx
    @y = playery
    @angle = playerangle
    @vel_x = 0
    @vel_y = 0
    @special = special
    @start_timer = $timer if @special

  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

   def move
    @x += @vel_x * 2
    @y += @vel_y * 2
    if @special
      @x %= 1280
      @y %= 960
    end
  end
  
  def draw
    @image.draw_rot(@x, @y, ZOrder::Projectile, @angle)
    self.accelerate
  end 

  def collect_stars(stars, projectiles)
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 200 then
        $score += 10
        @beep.play
        projectiles.delete self unless @special
        true
      else
        false
      end
    end
  end
end


class GameOverWindow < Gosu::Window
  def initialize
    super(1280, 960, false)
    self.caption = "Game over"
    @background_image = Gosu::Image.new(self, "assets/space.jpg", true)
  end
end


window = GameWindow.new
window.show