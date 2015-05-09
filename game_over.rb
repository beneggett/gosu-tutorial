class GameOverWindow < Gosu::Window
  def initialize
    super(1280, 960, false)
    self.caption = "Game over"
    @background_image = Gosu::Image.new(self, "assets/space.jpg", true)
  end
end
