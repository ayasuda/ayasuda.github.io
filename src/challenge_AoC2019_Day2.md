---
title: "今年はどのアドベントカレンダーにも投稿しないから、俺は AoC をただ解いていこうと思う。2 日目"
description: "ただただ Advent of Code 2019 を淡々とこなしていく記録"
date: '2019-12-02'
tags:
  - プログラミング問題
  - アドベントカレンダー
keywords:
  - プログラミング問題
  - アドベントカレンダー
  - Advento of Code
---

さて、2 日目。
サンタを乗せた宇宙船は無事発射されたようだ。現在はどうも月からスイングバイしているところとのこと。
ところがどっこい何かアラームが鳴り響いているようだ。うーん。怖い。

[https://adventofcode.com/2019/day/2](https://adventofcode.com/2019/day/2)

# 2 日目: 1202 Program Alarm

## 1 問目: コンピュータを作ろう！

管制センターのエルフによれば、俺は予備のスペアパーツで新しいコンピュータを作らなければならないらしい。

この「コンピュータ」で動かすプログラムはカンマ区切りの整数値で書かれている。

```
1,9,10,3,2,3,11,0,99,30,40,50
```

このプログラムは左から順番に読んでいき、命令が順番に書かれている。

まずは制御コードが 3 種類あり、`1`, `2`, `99` のいずれかだ。

`99` はプログラム終了で、`1` が加算、`2` が乗算だ。

`1`, `2` は制御コードと続く3 つの数字でひつの命令になる。
具体的には、制御コードの次の数字と2番目の数字で表される数字の数（わかりにくいなこれ）を加算または乗算して
3番目の数字で表される数字をそれに置き換える。

わかりにくいので具体例を示すと次の通りになる。

```
1,9,10,3,2,3,11,0,99,30,40,50
```

まず、最初の文字は `1` なので、 `1,9,10,3` で一つの命令となる。

続く `9,10` は、「このプログラムの9番目の数字、つまり30」と「このプログラムの10番目の数字、つまり40」の意味。
`3` が置き換え先なので、「このプログラムを3番目の数字を `30 + 40 = 70` にする」。

つまり、このプログラムの最初の命令を処理すると、プログラム自体がこうなる。

```
1,9,10,70,2,3,11,0,99,30,40,50
```

・・・という風にプログラムを処理するコンピュータ自体を、これから作っていくわけです。

幸いにもテスト用のプログラムと動かすとどのようになるかが問題文中に含まれているので、
まずはテスト用のファイルを用意して、昨日と同じようにこれらをただ出力するプログラムを書いて見ます。

```test.txt
1,0,0,0,99
2,3,0,3,99
2,4,4,5,99,0
1,1,1,4,99,5,6,0,99
```

```ruby:ans1.rb
#! /usr/bin/env ruby

def run(program)
  return program
end

program = ""

while l = gets
  program = l.strip.split(",").map(&:to_i)
end

result = run(program)
p result.join(",")
```

ちょっとただ出力するだけと見せかけて、 `strip` で改行文字を外して、`split` で配列化して `map(&:to_i)` で全て Integer にしています。

実行してみると以下の通り。

```console
cat test.txt | ./ans1.rb
"1,0,0,0,99"
"2,3,0,3,99"
"2,4,4,5,99,0"
"1,1,1,4,99,5,6,0,99"
```

続いて、プログラムの実行部分である、 `run` メソッドの内容を書いていきましょう。

一見すると、すごく難しそうに見えますが、少しずつ実装していけば思った以上に簡単に作れます。


今回は数値の列を順番に処理していくわけですから、ループで処理することはすぐに思いつくと思います。
ruby なので `program.each{|i| ... }` としたくなりますが、今回の「プログラム」はプログラム自身を書き換えていくので、
まずは無限ループを作って、配列の要素を一つずつみることにします。

```ruby:ans1.rb
def run(program)
  pos = 0
  while 1
    # program[pos] をごにょごにょする。
  end
end
```

次に制御コードによる分岐を作って行きます。
「プログラム」、つまり配列の要素の最初は制御コードになっているはずです。
というわけで、 `case` 文で分岐を書きましょう。ひとまず `99` のプログラム終了と、定義外の制御コードによるエラーを実装します。

```ruby:ans1.rb
OP_ADD = 1
OP_MULTI = 2
OP_HALT = 99

def run(program)
  pos = 0
  while 1
    case program[pos]
    when OP_HALT
      return program
    when OP_ADD
      # 加算処理書く
    when OP_MULTI
      # 乗算処理書く
    else
      # 謎の制御コードはエラーにする
      STDERR.puts "UNKWOWN OPERATION"
      exit -1
    end
  end
end
```

続いて加算を書いて行きましょう。
まず、制御コードの次の数字、２番目の数字、３番目の数字をそれぞれ取り出しましょう。

```ruby
i, j, o = program[pos+1], program[pos+2], program[pos+3]
```

後は、 `i`, `j` がさ示す数を足して、結果を `o` が指し示す場所に保存するだけです。
・・・というわけでこんなコードになります。

```ruby
program[o] = program[i] + program[j]
```

最後に、`pos` を「制御コード、次の数字、２番目の数字、３番目の数字」の次、つまり 4 つ進めれば加算部分は完成です。

```ruby
when OP_ADD
  i, j, o = program[pos+1], program[pos+2], program[pos+3]
  program[o] = program[i] + program[j]
  pos = pos + 4
```

乗算もおんなじ感じに実装すると、全体像はこんな感じです。


```ruby
#! /usr/bin/env ruby

OP_ADD = 1
OP_MULTI = 2
OP_HALT = 99

def run(program)
  pos = 0
  while 1
    case program[pos]
    when OP_HALT
      return program
    when OP_ADD
      i, j, o = program[pos+1], program[pos+2], program[pos+3]
      program[o] = program[i] + program[j]
      pos = pos + 4
    when OP_MULTI
      i, j, o = program[pos+1], program[pos+2], program[pos+3]
      program[o] = program[i] * program[j]
      pos = pos + 4
    else
      STDERR.puts "UNKWOWN OPERATION"
      exit -1
    end
  end
end

program = ""

while l = gets
  program = l.strip.split(",").map(&:to_i)
end

result = run(program)
p result.join(",")
```

ね！　簡単でしょ！

こいつを動かして見て、テストプログラムが動くか確認しましょう。

```
cat test.txt | ./ans1.rb
"2,0,0,0,99"
"2,3,0,6,99"
"2,4,4,5,99,9801"
"30,1,1,4,2,5,6,0,99"
```

と、まぁ、きちんと動いているのがわかるので、後は本番です。

Day1 と同じように、ユーザごとに「プログラム」が違うので、まずはそれをダウンロードして
`input.txt` とか名前をつけて保存しましょう。

そして、問題文の指示通り、2番目、3番目の数を書き換えてプログラムを実行し、
その最初の数を算出すればオッケーです！

## 2 問目: アラートの原因はなんだったのか。

さて、地上のエルフ氏が言うにはこの「コンピュータ」の最初の数字が
プログラムの出力になり、1番目と2番目の数字がプログラムへの入力となるようです。

そして、出力が 19690720 となる入力の組み合わせを見つけることで、宇宙船のアラートが止められるとのことです。

そんなわけで、プログラムを修正して行きましょう。

まず、入力のペアを走査するプログラムを作ります。

```ruby
(0..99).each do |n|
  (0..99).each do |v|
  end
end
```

そして、 `run` メソッドを `n`, `v` を取れるように改造します。
また、第一引数の `program` の渡し方を修正します。この「プログラム」は実行中に各種数値がどんどん変わっていくので、
そのまま渡さず `Array.dup` を使いコピーを渡すことにします。
最後に、 `run` メソッドの返り値を「プログラム」の出力に変更します。

```diff
- def run(program)
+ def run(program, n, v)
   pos = 0
+  program[1] = n
+  program[2] = v
   while 1
     case program[pos]
     when OP_HALT
-      return program
+      return program[0]
     when OP_ADD
       i, j, o = program[pos+1], program[pos+2], program[pos+3]
       program[o] = program[i] + program[j]
       pos = pos + 4
     when OP_MULTI
       i, j, o = program[pos+1], program[pos+2], program[pos+3]
       program[o] = program[i] * program[j]
       pos = pos + 4
     else
       STDERR.puts "UNKWOWN OPERATION"
       exit -1
     end
   end
 end

 (0..99).each do |n|
   (0..99).each do |v|
+    result = run(program.dup, n, v)
   end
 end
```

最後に、ターゲットとなる `19690720` と「プログラム」の出力が一致する `n, v` の組み合わせを見つけておしまいです！

```ruby
#! /usr/bin/env ruby

OP_ADD = 1
OP_MULTI = 2
OP_HALT = 99

def run(program, n, v)
  pos = 0
  program[1] = n
  program[2] = v
  while 1
    case program[pos]
    when OP_HALT
      return program[0]
    when OP_ADD
      i, j, o = program[pos+1], program[pos+2], program[pos+3]
      program[o] = program[i] + program[j]
      pos = pos + 4
    when OP_MULTI
      i, j, o = program[pos+1], program[pos+2], program[pos+3]
      program[o] = program[i] * program[j]
      pos = pos + 4
    else
      STDERR.puts "UNKWOWN OPERATION"
      exit -1
    end
  end
end

while l = gets
  program = l.strip.split(",").map(&:to_i)
end

target = 19690720

(0..99).each do |n|
  (0..99).each do |v|
    result = run(program.dup, n, v)
    if result == target
      puts 100 * n + v
      exit
    end
  end
end
STDERR.puts "NOT FOUND"
```

<!-- bursts into flames
magic somke -->
