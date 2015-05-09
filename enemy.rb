class Enemy
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
        ZOrder::Enemys, 1, 1)
    attack_player
  end


  def attack_player
    if $timer > 75 && Gosu::distance(@x, @y, @player.x, @player.y) < 200 && $timer % 5 == 0 then
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