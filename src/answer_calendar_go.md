---
title: 'カレンダー作成問題の解答 Go言語編'
date: '2019-05-06'
description: '初心者向けプログラミング問題の１つである「カレンダー作成問題」の解答コードと作り方をメモしていきます。'
tags:
  - Go
  - プログラミング問題
keywords:
  - Go
  - プログラミング問題
  - カレンダー
---

[アウトプットのネタに困ったらこれ！？Ruby初心者向けのプログラミング問題を集めてみた（全10問）](https://blog.jnito.com/entry/2019/05/03/121235)
で紹介された問題を解いてみようと思いました。

プログラマー歴1x年目。最近は手癖でプログラムを書いているので、意外にこの手の問題が解けなくなっているかもしれない……

なお、本記事では解答例は記事の最後に記します。
記事の冒頭で問題の紹介を抜粋します。次に、実装手順をつらつらと書いていきます。
ほら、いざって時には解答例じゃなくて、そこに至る手順が大事になることも多いですし。お寿司。
なお、今回は Go 言語を用いて解答していきたいと思います。
最後に解答例と発展例を示していきます。

# カレンダー作成問題

カレンダーを表示するプログラム実装で、問題自体は「たのしいRuby」に記載されているとのことです。

> Date クラスを使って、今月の１日と月末の日付と曜日を求め、次のような形式でカレンダーを表示させてください。

```
  April 2013
Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30
```

`cal` コマンドの再実装ですね！

# 手順

ポイントは日付処理用のライブラリの使い方です。問題文にヒントそのものが出ていますが、
今月の１日が何曜日なのかと、今月の最後の日付がわかれば多分できるでしょう。

## 今日の日付と time ライブラリ

さて、Go 言語で日付時刻を取り扱うなら [time](https://golang.org/pkg/time/) パッケージです。
なお、このパッケージはグレゴリオ暦が想定されており、また閏秒は想定されていません。
（ですので、この問題が「天保暦のカレンダーを表示せよ」とかだと対応できませんね笑）

まずはいつものコードを書いていきましょう。

```go:main.go
package main

import "fmt"

func main() {
  fmt.Plintln("vim-go")
}
```

早速、今日の日付と月末月初を表示してみましょう。

ひとまず、 [time.Now()](https://golang.org/pkg/time/#Now) で現時刻が取得できます。

> func Now() Time

この関数は [Time型](https://golang.org/pkg/time/#Time) を返します。この型はナノ秒単位での時刻を保持しているので
呼び出したタイミングによって値は異なります。

次のコードで実験してみましょう。

```go:main.go
package main

import (
  "fmt"
  "time"
)

func main() {
  fmt.Plintln(time.Now())
  fmt.Plintln(time.Now())
}
```

このコードを実行した結果は次の通りです。ナノ秒の値が異なっているのがわかるかと思います。

```console
$ go run main.go
2019-05-05 01:04:15.881271 +0900 JST m=+0.000507473
2019-05-05 01:04:15.881415 +0900 JST m=+0.000650832
```

さて、 `Time` 型には、年月日や時間を返す `func (Time) Year() int`, `func (t Time) Month() Month`, ` func (t Time) Day() int`, `func (t Time) Hour() int`
や、年月日の３項目を一気に返す `func (t Time) Date() (year int, month Month, day int)` などが用意されています。
なお、 `Month` 型は `type Month int` ですので、下記のコードは true になります。

```go
time.Febrary == 2 // true
time.November == 5 // false
```

月初に関してはこれらの関数の組み合わせと、 [time.Date](https://golang.org/pkg/time/#Date) を組み合わせると取得できそうです。

> func Date(year int, month Month, day, hour, min, sec, nsec int, loc \*Location) Time

## 月末の求め方 1: time.Date を使う

月末に関してはどうでしょう？
月の日数は月によって違います。また２月は閏年かどうかによって異なります。
この辺のコードを愚直に書くとこんな感じになります。

```go:main.go
package main

import (
	"fmt"
	"time"
)

func main() {
	n := time.Now()
	f := time.Date(n.Year(), n.Month(), 1, 0, 0, 0, 0, time.Local) // 月初
	l := time.Date(n.Year(), n.Month(), lastDay(n), 0, 0, 0, 0, time.Local) // 月末
	fmt.Println(n)
	fmt.Println(f)
	fmt.Println(l)
}

// lastDay は月末の日付を数値で返します
func lastDay(t time.Time) int {
	switch t.Month() {
	case time.January, time.March, time.May, time.July, time.August, time.October, time.December:
		return 31
	case time.April, time.June, time.September, time.November:
		return 30
	case time.February:
		if IsLeapYear(t) {
			return 29
		} else {
			return 28
		}
	default:
		return 1
	}
}

// IsLeapYear は閏年なら true を返します
func IsLeapYear(t time.Time) bool {
	y := time.Date(t.Year(), time.December, 31, 0, 0, 0, 0, time.Local)
	days := y.YearDay()

	if days > 365 {
		return true
	} else {
		return false
	}
}
```

## 月末の求め方 2: time.Add を使い、次の月の月初から1日マイナスする

月末の日付を求めるやり方の別解として、次の月の月初から１日マイナスするという方法もあるでしょう。
この場合は、現在時刻が12月の場合だけ気をつける必要があります。

また、日付の加算・減算には `func (t Time) Add(d Duration) Time` を使います。

```go:main.go
package main

import (
	"fmt"
	"time"
)

func main() {
	n := time.Now()
	f := time.Date(n.Year(), n.Month(), 1, 0, 0, 0, 0, time.Local)
	l := lastDay(n)
	fmt.Println(n)
	fmt.Println(f)
	fmt.Println(l)
}

// lastDay は指定月の最終日を返します。
func lastDay(n time.Time) time.Time {
	var f time.Time
	if n.Month() == time.November {
		f = time.Date(n.Year()+1, time.January, 1, 0, 0, 0, 0, time.Local)
	} else {
		f = time.Date(n.Year(), n.Month()+1, 1, 0, 0, 0, 0, time.Local)
	}
	return f.Add(time.Hour * 24 * -1)
}
```

個人的には後者のコードの方がスッキリしていて良いと思います。

## 月初は何曜日？

実に単純ですが、`func (t Time) Weekday() Weekday` を使います。
なお、 `Weekday` 型は `type Weekday int` です。

## 表示部分を作っていこう

あとは、表示部分を作っていくだけです。
ただただ愚直に作るので、記事としてはあまり面白くないかもしれません笑

### 年・月表記とセンタリング

月名の表示は `func (m Month) String() string` を使えばすぐにできます。
また今回のプログラムでは、表示の横幅が次の通り、`Su Mo Tu We Th Fr Sa` 20 文字で固定です。
ですので、月名の長さを `n` とすると、 `(20 - (n + 5)) / 2` 個のスペースを左側に挿入すると、いい感じにセンタリングできるはずです。
そんなわけで、最初の月名表示の部分は下記の様なコードになります。

```go:main.go
package main

import (
  "fmt"
  "strings"
  "time"
)

func main() {
  n := time.Now()
  ms := n.Month().String()
  ls := (20 - (len(ms) + 5)) / 2
  fmt.Printf("%s%s %d\n", strings.Repeat(" ", ls), ms, n.Year())
}
```

### カレンダー表示部分

この部分も愚直にやっていくのが良いでしょう。

今回の私は、 1 から日数分のループを回すことをベースに実装しました。
その際、最初の週の左インデントの量を月初の曜日によって変えつつ、
どのタイミングで改行を挟むかも月初の曜日によって変えるコードを用意しました。

最終的な実装例は、以下の通りとなります。

# 解答例

ソースコードは [こちら](https://github.com/ayasuda/sandbox/blob/master/go_cal/main.go) にあります。

```go:main.go
package main

import (
	"fmt"
	"strings"
	"time"
)

func main() {
	n := time.Now()
	f := time.Date(n.Year(), n.Month(), 1, 0, 0, 0, 0, time.Local)
	l := lastDay(n)

	ms := n.Month().String()
	ls := (15 - len(ms)) / 2
	fmt.Printf("%s%s %d\n", strings.Repeat(" ", ls), ms, n.Year())

	var idt, cnt int
	switch f.Weekday() {
	case time.Sunday:
		idt = 0
		cnt = 6
	case time.Monday:
		idt = 3
		cnt = 5
	case time.Tuesday:
		idt = 6
		cnt = 4
	case time.Wednesday:
		idt = 9
		cnt = 3
	case time.Thursday:
		idt = 12
		cnt = 2
	case time.Friday:
		idt = 15
		cnt = 1
	case time.Saturday:
		idt = 18
		cnt = 0
	}
	fmt.Println("Su Mo Tu We Th Fr Sa")
	fmt.Printf("%s", strings.Repeat(" ", idt))
	for i := 1; i <= l.Day(); i++ {
		if i < 10 {
			fmt.Printf(" %d", i)
		} else {
			fmt.Printf("%d", i)
		}
		if cnt <= 0 {
			fmt.Printf("\n")
			cnt = 6
		} else {
			fmt.Printf(" ")
			cnt--
		}
	}
	fmt.Printf("\n")
}

func lastDay(n time.Time) time.Time {
	var f time.Time
	if n.Month() == time.November {
		f = time.Date(n.Year()+1, time.January, 1, 0, 0, 0, 0, time.Local)
	} else {
		f = time.Date(n.Year(), n.Month()+1, 1, 0, 0, 0, 0, time.Local)
	}
	return f.Add(time.Hour * 24 * -1)
}
```

# 発展例に向けて

今回のカレンダー問題は、 `cal` コマンドの簡易実装そのものです。ですので、実際の `cal` コマンド実装が大変参考になります。
また、cal コマンドのオプションを自前で実装してみるのも勉強になるでしょう。

以下、個人的に興味深かった `cal` コマンドの現実の実装例を抜粋して紹介してみたいと思います。

linux での cal 実装は下記にあります。

[https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c](https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c)

この実装では、月の日数を割とハードコード目に実装しているのが興味深いです。

[https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c#L193](https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c#L193)

```c
static const int days_in_month[2][13] = {
        {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31},
        {0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31},
};
```

カレンダー部分の表示では、複数月の表示に対応したコードが書かれています。
809行目からの１週当たりの表示部分は鮮やかですね。

[https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c#L787](https://github.com/karelzak/util-linux/blob/master/misc-utils/cal.c#L787)

FreeBSD での実装は以下にあります

[https://github.com/freebsd/freebsd/blob/master/usr.bin/ncal/ncal.c](https://github.com/freebsd/freebsd/blob/master/usr.bin/ncal/ncal.c)

年単位での表示がサポートされているので大変そうです笑

ちなみに、 macOS とかで `cal` コマンドを `CAL` と呼ぶと縦横が転置して表示されますよね？

```
$ cal
      5月 2019
日 月 火 水 木 金 土
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31

$ CAL
    5月 2019
月      6 13 20 27
火      7 14 21 28
水   1  8 15 22 29
木   2  9 16 23 30
金   3 10 17 24 31
土   4 11 18 25
日   5 12 19 26
```

この辺の動きは

```c
  /*
   * Get the filename portion of argv[0] and set flag_backward if
   * this program is called "cal".
   */
   if (strncmp(basename(argv[0]), "cal", strlen("cal")) == 0)
           flag_backward = 1;
```
[https://github.com/freebsd/freebsd/blob/master/usr.bin/ncal/ncal.c#L249](https://github.com/freebsd/freebsd/blob/master/usr.bin/ncal/ncal.c#L249)

にある通り、 `cal` という名前で呼び出さなかった時に、 `cal -N` をつけた時と同じ動きになる実装通りですね！
