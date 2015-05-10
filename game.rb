class GameWindow < Gosu::Window
  def initialize
    # height, width, fullscreen
    super(1280, 960, false)
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new(self, "assets/space.jpg", true)

    @player = Player.new(self)
    @player.warp(640, 480)

    @enemy_anim = Gosu::Image::load_tiles(self, "assets/monster.png", 430, 385, false)

    @enemies = Array.new
    @projectiles = Array.new

    @font = Gosu::Font.new(self, Gosu::default_font_name, 36)
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
      @projectiles.delete projectile if projectile.special && (projectile.enemy_timer + 250) < $timer
      projectile.collect_enemies(@enemies, @projectiles)
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
    if rand(100) < 4 and @enemies.size < size then
      @enemies.push(Enemy.new(@enemy_anim, self, @player))
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
    @enemies.each { |enemy| enemy.draw }
    @projectiles.each{ |projectile| projectile.draw }
    @font.draw("Energy: #{$score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Specials: #{$specials}", 500, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw("Level: #{$level}", 1000, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::CYAN)
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