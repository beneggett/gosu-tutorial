require 'gosu'
%w( game.rb enemy.rb player.rb projectile.rb game_over.rb z_order.rb ).each { |lib| load lib }

window = GameWindow.new
window.show
