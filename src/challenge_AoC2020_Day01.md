---
title: "去年は４日で挫折したけど、俺は AoC をただ解いていこうと思う。1 日目"
description: "ただただ Advent of Code 2020 を淡々とこなしていく記録"
date: '2020-12-01'
tags:
  - プログラミング問題
  - アドベントカレンダー
keywords:
  - プログラミング問題
  - アドベントカレンダー
  - Advento of Code
---

毎年催されている季節イベントの一つに [Advent of Code](https://adventofcode.com/2020) というのがある。

要はアドベントカレンダーみたいに、12/1から12/25まで、毎日出題されるプログラミングの問題をただ解き続けるというイベントだ。

去年は５日目で問題を突破できなくなってしまったが、今年もチャレンジしたい。

# Adovent of Code のルール

今年も例年通り。

基本的には１日２題出題される。

１問目が基本問題、２問目が応用問題という感じだ。

１問解くごとに、星が１つもらえ、最終的には５０個の星を集める必要がある。

１問ごとに挑戦者ごとに異なった入力が与えられるので、プログラムを書いて（または手で計算したって良い）答えを入力すると次に進める寸法だ。

# 1 日目: Report Repair

## Part 1

今年は Go 言語を使おうと思うので、基本的なセットをさっさと組んでおこう。

リポジトリを用意し、day01 ディレクトリを用意し、 input.txt をその中に置く。
input.txt の中身は、 https://adventofcode.com/2020/day/1/input からコピーしておく。

Go 言語で「ファイルから１行ずつ読み込む」処理は以下のパターン。
どうせ使うので用意しておく。

```golang
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	f, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		fmt.Println(scanner.Text()) // Println will add back the final '\n'
	}
	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}
}
```

問題は単純で、 *合計すると 2020 になる2つの数字の組み合わせを見つける* こと。
そして、見つかった2つの数字を掛け合わせた数が答えとなる。
例えば `1721` と `299` が入力値に両方とも含まれているなら、 `1721 * 299 = 514579` が答えとなる。

Go 言語での文字列 -> 数値変換は [strconv.Atoi](https://golang.org/pkg/strconv/#Atoi) で行う。

```
package main

import (
	"fmt"
	"strconv"
)

func main() {
	v := "10"
	if s, err := strconv.Atoi(v); err == nil {
		fmt.Printf("%T, %v", s, s)
	}
}
```

後は、ファイルを１行読むごとに、今まで出てきた数値との合計が `2020` になる組み合わせを探せば良いので、
単純に配列を用意し、ファイルを１行読むごとに組み合わせをチェックする。

```golang
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	f, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	s := bufio.NewScanner(f)
	a := []int{}
	for s.Scan() { // ファイルから１行読むごとに・・・

		i, err := strconv.Atoi(s.Text()) // Atoi で int 型にし
		if err != nil {
			log.Fatal(err)
		}
		for _, j := range a { // 今まで出てきた数値から合計が 2020 になるものを探し
			if i+j == 2020 {
				fmt.Printf("%d", i*j) // あれば掛け算して出力する
			}
		}

		a = append(a, i) // ないなら配列に数値を保存する　
	}
	if err := s.Err(); err != nil {
		log.Fatal(err)
	}
}
```

## Part 2

同じ条件になる *３つの数字の組み合わせ* を見つけるだけ。

まぁ、おんなじようにプログラムを書けばオッケーでしょう。

```golang

package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	f, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	s := bufio.NewScanner(f)
	a := []int{}
	for s.Scan() {
		i, err := strconv.Atoi(s.Text())
		if err != nil {
			log.Fatal(err)
		}
		for _, j := range a {
			for _, k := range a {
				if i+j+k == 2020 {
					fmt.Printf("%d\n", i*j*k)
					return // 結果出たらすぐに走査を打ち切る。
				}
			}
		}

		a = append(a, i)
	}
	if err := s.Err(); err != nil {
		log.Fatal(err)
	}
}
```

１日目はこんなもんでしょ。
優しい。

１日目までのコードはこちら。
[https://github.com/ayasuda/advent_of_code_2020/tree/main/day01](https://github.com/ayasuda/advent_of_code_2020/tree/main/day01)

https://twitter.com/ayasuda_jp/status/1333804526717919232
