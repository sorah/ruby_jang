#和了形クラス。和了形の面子の解釈の状態を保持
class Agari
    def initialize(tehai,tsumohai,mentsus,player,tsumo=true)
        @pais = tehai
        @pai = tsumohai
        @tehai = @pais.dup.push(@pai)
        #ツモ上がりしたかどうか
        @tsumo = tsumo
        #面子のスタックをそのまま格納
        #おそらく容量５で頭＋面子*4が格納されているはず
        @mentsus = mentsus.dup
        #役の一覧
        @yakus = Array.new
        @player = player
        #面前かどうか（全ての面子を検索して、全てが副露してないとき）
        @menzen = menzen?
    end
    #面前かどうか調べる
    def menzen?
        b = true
        @mentsus.each do |m|
            if m.fooroh
                b = false
                break
            end
        end
        return b
    end
    def get_yaku
        if @mentsus.length == 1
            #国士無双形の場合
            kokushi?
        else
            if @mentsus.length == 7
                #七対子形の場合
                @yakus.push(Yaku.new("七対子",2))
            end
            puts "-----------------"
            @mentsus.each do |m|
                m.ex_pais
            end
            tanyao?
            pinhu?
            yakuhai?
            epei?
            ryanpei?
            toitoi?
            sanan?
            suan?
            sankan?
            sukan?
            doujyun?
            doukou?
            ittu?
            honroh?
            honitsu?
            chanta?
            dsangen?
            ssangen?
            chinroh?
            tooe?
        end
        @yakus.each do |y|
            puts y.get_name
        end

    end
    #点数を計算する
    def get_score
        #yakus配列を全て調査
        #一つでも役満があったら、役満以外を消去
        #役満がなかったら、役の合計から半数を求める。
        #数え役満はとりあえずなしの方向で（合計が13飜以上になったときに別処理）
        get_yaku
        return 0
    end
    #各役の判定
    #断ヤオ
    #ヤオ九牌が０こならtrue
    #暫定的に喰い断を認める
    def tanyao?
        f = @tehai.count_yaochu == 0
        if f
            @yakus.push(Yaku.new("タンヤオ",1))
        end
        return f
    end
    #平和
    #面子が全て順子である
    #待ち牌が両面待ちである
    #役牌が含まれていない。
    def pinhu?
        r = true
        #全ての面子の種類が１で、かつ手牌に全て含まれている。
        @mentsus[1...@mentsus.length].each do |m|
            if m.get_kind != 1
                r = false
            end      
        end
        if @mentsus.first.get_pais.first.yakuhai?(@player.kaze)
            r = false
        end
        if !@menzen
            r = false
        end
        if r
            @yakus.push(Yaku.new("平和",1))
        end
    end
    #役牌
    #刻子かつ、牌が役牌である
    def yakuhai?
        @mentsus.each do |m|
            if m.get_kind == 3 
                if m.get_pais.first.jikaze? && m.get_pais.first.bakaze?
                    #ダブ東、ダブ南
                    @yakus.push(Yaku.new("役牌",2))
                elsif m.get_pais.first.yakuhai?
                    @yakus.push(Yaku.new("役牌",1))
                end
            end
        end
    end
    #一盃口
    #面子をuniqしたとき、長さが4になればよい（重複が1種類ある）
    def epei?
        if @mentsus.uniq.length == 4 && @menzen 
            @yakus.push(Yaku.new("一盃口",1))
        end
    end
    #二盃口
    #面子をuniqしたとき、長さが3になればよい（重複が2種類ある）
    def ryanpei?
        if @mentsus.uniq.length == 3 && @menzen 
            @yakus.push(Yaku.new("二盃口",3))
        end
    end
    #対々和
    #刻子が４つある
    def toitoi?
        c = 0
        @mentsus.each do |m|
            if m.get_kind == 2
                c+=1
            end
        end
        f = c == 4
        if f
            @yakus.push(Yaku.new("対々和",2))
        end
        return f
    end
    #三暗刻
    def sanan?
        #暗刻が３つある
        c = 0
        @mentsus.each do |m|
            if m.get_kind == 2
                c+=1
            end
        end
        if c > 3
            @yakus.push(Yaku.new("三暗刻",2))
        end
        return c >= 3
    end
    #三色同順
    #順子が３つ以上の時
    def doujyun?
        f = false
        colors = Array.new(3,false)
        syuntsu = @tehai.search_syuntsu
        #三種類あるか調査
        if syuntsu.length >=3
            syuntsu.each do |s|
                colors[s.get_pais.first.kind] = true
            end
            #全て同じ順子かチェック
            if colors[0] && colors[1] && colors[2]
                f = true
                syuntsu.each do |s|
                    syuntsu.each do |t|
                        if !s.same_number?(t)
                            f = false
                            break
                        end
                    end
                end
            end
        end
        if f
            @yakus.push(Yaku.new("三色同順",2))
        end
        return f
    end
    #三色同刻
    def doukou?
        f = false
        colors = Array.new(3,false)
        koutsu = @tehai.search_koutsu
        #三種類あるか調査
        if koutsu.length >=3
            koutsu.each do |k|
                colors[k.get_pais.first.kind] = true
            end
            #全て同じ順子かチェック
            if colors[0] && colors[1] && colors[2]
                f = true
                koutsu.each do |s|
                    koutsu.each do |t|
                        if s.same_number?(t)
                            f = false
                            break
                        end
                    end
                end
            end
        end
        if f
            @yakus.push(Yaku.new("三色同刻",2))
        end
        return f
    end
    #小三元
    def ssangen?
        a = @mentsus.first.get_pais.first.sangen?
        c = 0
        @mentsus.each do |m|
            if m.get_kind == 2 && m.get_pais.first.sangen?
                c +=1
            end
        end
        f = a && c>2
        if f
            @yakus.push(Yaku.new("小三元",2))
        end
        return f
    end
    #一気通貫
    #同じ種類の牌が9種類以上
    #1~9の全ての数字がある
    def ittu?
        (0..2).to_a.each do |k|
            flag = true
            (1..9).to_a.each do |n|
                p = Pai.new(k,n)
                if @tehai.count(p) ==0
                    flag = false
                end
            end
            if flag
                @yakus.push(Yaku.new("一気通貫",2))
                break
                return true
            end
        end
    end
    #混老頭
    #ヤオ九牌の合計が14であるかどうか
    def honroh?
        f = @tehai.count_yaochu == 14
        if f
            @yakus.push(Yaku.new("混老頭",2))
        end
        return f
    end
    #チャンタ・純チャン
    def chanta?
        cflag = true
        jflag = true
        @mentsus.each do |m|
            if m.get_pais.select{|p|p.hashihai?}.empty?
                jflag = false
                cflag = false
            elsif m.get_pais.select{|p|(p.hashihai?||p.jihai?)}.empty?
                cflag = false
            end
        end
        if jflag
            @yakus.push(Yaku.new("純チャン",3))
        elsif cflag
            @yakus.push(Yaku.new("チャンタ",2))
        end
        return jflag || cflag

    end
    #混一色・清一色
    def honitsu?
        kind = nil
        #0清一色1混一,2何でもない
        f = 0
        @tehai.each do |p|
            if p.jihai?
                f = 1
            else
                if !kind.nil?
                    if kind!=p.kind
                        f=2
                        break
                    end
                end
                kind = p.kind
            end
        end
        if f==0
            @yakus.push(Yaku.new("清一色",6))
            return true
        elsif f==1
            @yakus.push(Yaku.new("混一色",2))
            return true
        else
            return false
        end
    end
    #三槓子
    def sankan?
        f = true
        c = 0
        @mentsus[1...@mentsus.length].each do |m|
            unless m.get_kind == 3
                c +=1
            end
        end
        if c==3
            @yakus.push(Yaku.new("三槓子",2))
        end
        return f
    end
    #############
    #役満
    #############
    #四暗刻（単騎含め）
    def suan?
        c = 0
        @mentsus.each do |m|
            if m.get_kind == 2
                c+=1
            end
        end
        #手牌の中に暗刻が４つあれば、四暗刻単騎
        if @pais.search_ankou.length ==4
            @yakus.push(Yaku.new("四暗刻（単騎）",26))
            f = true
            #手牌、ツモ牌含めた中に４つあれば、四暗刻
        elsif c == 4
            @yakus.push(Yaku.new("四暗刻",13))
            f = true
        end
        return c==4
    end
    #大三元
    def dsangen?
        c = 0
        @mentsus.each do |m|
            if m.get_kind == 2 && m.get_pais.first.sangen?
                c +=1
            end
        end
        f = c>3
        if f
            @yakus.push(Yaku.new("大三元",13))
        end
        return f
    end
    #字一色
    def tooe?
        f = true
        @tehai.each do |p|
            if !p.jihai?
                f = false
            end
        end
        if f
            @yaku.push(Yaku.new("字一色",13))
        end
        return f
    end
    #緑一色
    #清老頭
    def chinroh?
        f = false
        if @tehai.count_yaochu == 14
            f = true
            @tehai.each do |p|
                if p.jihai?
                    f = false
                    break
                end
            end
        end
        if f
            @yaku.push(Yaku.new("清老頭",13))
        end
        return f
    end
    #大四喜
    #小四喜
    #四槓子
    def sukan?
        f = true
        @mentsus[1...@mentsus.length].each do |m|
            unless m.get_kind == 3
                f = false
            end
        end
        if f
            @yakus.push(Yaku.new("四槓子",13))
        end
        return f
    end
    #九蓮宝燈
    #国士無双
    def kokushi?
        r = false
        #対子が一つである
        if @tehai.search_heads.length ==1
            #手牌が全てヤオ九牌である
            if @tehai.count_yaochu==14
                #手牌の種類を調べて、13種類あれば国士無双
                if @pais.count_kinds ==13    
                    r = true
                    @yakus.push(Yaku.new("国士無双（単騎待ち）",26))
                elsif @tehai.count_kinds ==13
                    @yakus.push(Yaku.new("国士無双",13))
                    r = true
                end
            end
        end
        return r
    end

end
