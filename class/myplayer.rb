require "class/player"
class Myplayer < Player
    def initialize(n)
        super(n)
    end
    def get_tehai
        return @pais+@pai 
    end
    def render_tehai
        @pais.each_with_index do |p,i|
            p.set_pos(20+i*33,320)
        end
        @pai.set_pos(20+13.5*33,320)
    end
    def ex_tehai
        ripai
        @pais.each do |p|
            puts p.get_name
        end
        puts ""
        puts @pai.get_name
    end
    #手牌をデバッグ用の牌にする
    def debug
        @pais = Tehai.new([
                          Pai.new(1,1),
                          Pai.new(1,9),
                          Pai.new(2,1),
                          Pai.new(2,9),
                          Pai.new(0,1),
                          Pai.new(0,9),
                          Pai.new(3,1),
                          Pai.new(3,2),
                          Pai.new(3,3),
                          Pai.new(3,4),
                          Pai.new(3,5),
                          Pai.new(3,6),
                          Pai.new(3,7)
        ])
        tsumo(Pai.new(1,3))
    end
end
