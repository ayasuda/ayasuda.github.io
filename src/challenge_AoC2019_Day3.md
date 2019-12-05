---
title: "今年はどのアドベントカレンダーにも投稿しないから、俺は AoC をただ解いていこうと思う。3 日目"
description: "ただただ Advent of Code 2019 を淡々とこなしていく記録の3日目"
date: '2019-12-05'
keywords:
  - プログラミング問題
  - AdventCalender
---

さて、3 日目。今日は 12/5 だが・・・
サンタを乗せた宇宙船はスイングバイに無事成功し、一路金星へ向かっているようだ。
ただ、あわてんぼうのサンタクロースさんはとても慌てていたようで、燃料管理システムが完全にはインストールされていなかったようだ。
そんなわけで、そいつをやる。

[https://adventofcode.com/2019/day/2](https://adventofcode.com/2019/day/2)

# 3 日目: Crossed Wires

## 1 問目: パネルを開けたら、そこは、ワイヤーの天国でした。

制御ボードを開けてみるとごちゃごちゃしたワイヤーが見える。
これらのワイヤーは片方は必ず中央ポートに、もう片方はグリッドの外へと繋がっている。
また、ワイヤーは折れ曲がって繋がっている。
例えば、下記のようにワイヤーのパスが定義されているとすると

```
R8,U5,L5,D3
```

これは、ワイヤーが中央ポートから始まって右へ 8 、上へ 5 、左へ 5 、下へ 3 進み、そこからグリッドの外へと繋がっている。

こんな風に複数のワイヤーが制御ボード上へ配置されているわけだが、これらのワイヤーは時たま交差する。

燃料管理システムを完璧なものにするためには、中央ポートから最も近い交差地点を見つけ、中央ポートとの [マンハッタン距離](https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%B3%E3%83%8F%E3%83%83%E3%82%BF%E3%83%B3%E8%B7%9D%E9%9B%A2) を
算出する必要がある。

まず、テスト用のファイルを用意する。

```
R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83
```

移動用の数字をパースするプログラムを書いて行こう。
まずはいつも通り、標準入力から定義を読み込む部分を作る。

```ruby
#! /usr/bin/env ruby

def cordinates(directions)
  directions
end

while l = gets
  directions = l.strip.split(",")
  p cordinates(directions)
end
```

次に、`cordinates` メソッドを実装していく。
こいつは入力を基に、ワイヤーが通過する座標を列挙した配列を返すメソッドにする予定だ。

まずは、方向指示をパースしよう。こんな風にできる。

```ruby
direction, magnitude = d[0], d[1,d.length()-1].to_i
```

後は、方向を考慮して、ただひたすら、座標を記録していくだけだ。
実装はこんな感じになる。

```ruby
#! /usr/bin/env ruby

def cordinates(directions)
  cordinates = []
  current = [0, 0]
  directions.each do |d|
    direction, magnitude = d[0], d[1,d.length()-1].to_i
    case direction
    when "U"
      magnitude.times do
        current[1] += 1
        cordinates << current.dup
      end
    when "R"
      magnitude.times do
        current[0] += 1
        cordinates << current.dup
      end
    when "D"
      magnitude.times do
        current[1] -= 1
        cordinates << current.dup
      end
    when "L"
      magnitude.times do
        current[0] -= 1
        cordinates << current.dup
      end
    else
      STDERR.puts = "UNKNOWN DIRECTION :" + d
    end
  end
  cordinates
end

while l = gets
  directions = l.strip.split(",")
  p cordinates(directions)
end
```

動かしてみると、まぁいい感じになっている。

```console
% cat test1.tsv| ./ans1.rb
[[1, 0], [2, 0], ...(中略)..., [74, 0], [75, 0], [75, -1] ...(後略)
```

後は、２つのワイヤーから、共通する座標を抜き出せばそれで良い。

ruby の場合、2つの配列で `&` をとればすぐに抜き出せる。

共通する座標の原点とのマンハッタン距離の最小値を出すとこんな感じになる。

```
paths = []

while l = gets
  directions = l.strip.split(",")
  paths << cordinates(directions)
end

cross = paths[0] & paths[1]

p cross.map{|c| c[0].abs + c[1].abs }.min
```

試してみよう。


```console
% cat test1.tsv| ./ans1.rb
159
```

いい感じ。

これで制御ボード上で、最も中央ポートに近い交差地点がわかった。

## 2 問目: アラートの原因はなんだったのか。

さて、次は交差地点へのステップ数を求めなきゃいけないらしい。

ここまで出来てればほとんど出来上がったようなもんです。


```ruby
crosses = paths[0] & paths[1]

steps = corsses.map{|c| paths[0].index(c) + paths[1].index(c) + 2 }

p steps.min
```

こいつも動きを試してみると・・・

```console
% cat test1.tsv| ./ans1.rb
610
```

うん。出来た。
