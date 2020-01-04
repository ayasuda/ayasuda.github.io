---
title: "今年はどのアドベントカレンダーにも投稿しないから、俺は AoC をただ解いていこうと思う。1 日目"
description: "ただただ Advent of Code 2019 を淡々とこなしていく記録"
date: '2019-12-01'
tags:
  - プログラミング問題
  - アドベントカレンダー
keywords:
  - プログラミング問題
  - アドベントカレンダー
  - Advento of Code
---

今年もアドベントカレンダーの季節が来た。
しかし、友達がいないので、俺はどのアドベントカレンダーにも参加していない。
そんな孤独感を紛らわせるためにも [Advent of Code](https://adventofcode.com/2019) にチャレンジしていこうと思ったんだ。

# 1 日目: The Tyranny of the Rocket Equation

## 1 問目：さっさと燃料を計算する簡単なお仕事。

どうやら俺は宇宙にいるサンタのがクリスマスまでの地球への帰還に間に合うように、
エルフたちに彼の宇宙船に必要な燃料を伝達する必要があるようだ。

各モジュールごとへの必要な燃料は下記の方法で算出できる。

> Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.

いたってシンプルなので、サクッと以下の ruby コードで計算させてみる

```ruby:ans.rb
#! /usr/bin/env ruby
m = 12
p m / 3 - 2
```

・・・あんまりにも単純すぎるので、問題を解きやすく改善する。

この問題では、入力は見ての通り数値が1 行ごとに書かれたテキストで提供される。
そんなわけで、標準入力から数値を受け取って標準出力に表示するようにしよう。

```ruby:ans.rb
#! /usr/bin/env ruby

while l = gets
  p l.to_i / 3 - 2
end
```

テスト用のファイルを用意して・・・

```text:test.tsv
12
14
1969
100756
```

以下のコマンドで実行する。

```
$ cat test.tsv | ./ans.rb
2
2
654
33583
```

というわけで正しく動いていそうなので合計値を表示するようにし...

```ruby:ans.rb
#! /usr/bin/env ruby

a = 0
while l = gets
  f = l.to_i / 3 - 2
  p f
  a += f
end
p a
```

早速計算させてみよう。

```console
$ curl https://adventofcode.com/2019/day/1/input
Puzzle inputs differ by user.  Please log in to get your puzzle input.
```

と、思ったらネタバレ対策されてたので、安心して input を tsv に保存して実行する。

```console
$ cat input.tsv | ./ans.rb
```

当たり前のようにパスしたので２問目へ。

## (ネタバレ) 2 問目：燃料自体の重さもあるよね？　って話。

タイトル通り。

燃料自体の重さがないと、宇宙船は途中で力尽きてしまうわけですよ。

今回の問題では以下のルールで計算を求められる。

1. 燃料に必要な燃料の計算式はさっきまでと同じ。3 で割って、2を引く。例えば 10 の燃料に必要な燃料は 1 。
2. マイナスになる場合は、0とする。例えば 5 の燃料に必要な燃料は 0 。
3. 燃料に必要な燃料に必要な燃料（以下略）も計算すること！

例えば、モジュールの質量が 1969 なら、

* モジュールに必要な燃料は 654
* それに必要な燃料は 216
* それに必要な燃料は 70
* それに必要な燃料は 21
* それに必要な燃料は 5
* それに必要な燃料は -1... じゃなくて 0

なので、合計 966 になる。

うん。つまりは再帰が求められている。

・・・と、いうわけでサクッと以下のプログラムを書く

```ruby:ans.rb
#! /usr/bin/env ruby

def calc(mass)
  fuel = mass / 3 - 2
  return 0 if fuel <= 0
  fuel + calc(mass)
end

a = 0
while l = gets
  f = calc(l.to_i)
  p f
  a += f
end
p a
```

こいつを早速 test.tsv にかましてみると　

```console
$ cat test.tsv | ./ans.rb
2
2
966
50346
51316
```

と、まぁまぁいい感じで計算できているので、早速実行する。

```console
$ cat input.tsv | ./ans.rb
```

まぁ、1 日目なので普通にクリアできますよね。

https://twitter.com/ayasuda_jp/status/1201345178805473280
