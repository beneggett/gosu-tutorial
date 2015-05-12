class Enemy
  attr_accessor :x, :y, :window, :player, :life

  def initialize(animation, window, player, life = 1)
    @animation = animation
    @x = rand * 1280
    @y = rand * 960
    @player = player
    @window = window
    @life = life
    @font = Gosu::Font.new(window, Gosu::default_font_name, 50)
    @color = Gosu::Color.new(0xff000000)
    @color.red = @color.green = @color.blue = 255
    if life > 1
      @color.red = rand(256 - 40) + 40
      @color.green = rand(256 - 40) + 40
      @color.blue = rand(256 - 40) + 40
    end
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Enemies, 1, 1, @color)
    @font.draw("️#{'♥' * life}", x, y + 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::FUCHSIA)
    attack_player
  end


  def attack_player
    if $timer > 100 && Gosu::distance(@x, @y, @player.x, @player.y) < 200 && $timer % 5 == 0 then
      dmg = 1
      case 
      when $level < 2
        dmg +=1
      when $level < 5
        dmg +=2
      when $level < 10
        dmg +=3
      when $level < 20
        dmg +=4
      when $level < 30
        dmg +=8
      when $level < 50
        dmg +=15
      when $level < 60
        dmg +=25
      when $level < 75
        dmg +=50    
      when $level < 90
        dmg +=75      
      else
        dmg += rand(75..500)
      end        
      $score -= dmg
      @punch = Gosu::Sample.new(window, "assets/punch.mp3").play
      true
    else
      false
    end
  end

end