
class Projectile
  attr_accessor :enemy_timer, :special
  def initialize(window, playerx, playery, playerangle, special = false)
    @special = special
    @beep = Gosu::Sample.new(window, "assets/coin_sound.wav")
    @fire = Gosu::Sample.new(window, "assets/hadouken.mp3").play
    @image = Gosu::Image.new(window, ["assets/hadouken.png", "assets/hadouken-red.png"].sample)
    @image = Gosu::Image.new(window, "assets/hadouken-green.png") if @special
    @x = playerx
    @y = playery
    @angle = playerangle
    @vel_x = 0
    @vel_y = 0
    @enemy_timer = $timer if @special
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

  def collect_enemies(enemies, projectiles)
    enemies.reject! do |enemy|
      if Gosu::distance(@x, @y, enemy.x, enemy.y) < 200 then
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