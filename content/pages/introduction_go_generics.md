---
title: "ぼくのための Generics (Go 言語) 入門"
description: "Genercis がなぜ欲しいのか？　とその基本的な構文について"
date: '2024-07-24'
tags:
  - Go
  - Generics
keywords:
  - Go 言語
  - Generics
  - Generic Programming
---

なぜプログラミング言語に Generics 機能が必要なのか？　その理由を忘れることが多々あります。

なので、本ぺージでは自分の理解のために、[Why Generics? - The Go Programing Language] の内容を抜粋・再整理しました。

# Generics とは何か？ - Generic Programing の何が嬉しいのか？

まずはそもそも論として [Generic Programming](https://www.dagstuhl.de/en/seminars/seminar-calendar/seminar-details/98171) について整理しておきます

Generic Programming はプログラミングスタイルの１つで、特定の型に依存しないロジックやアルゴリズムを記述し、それと様々なデータ表現・型とを組み合わせる手法で、
[Musser & Stepanov (1989)](https://doi.org/10.1007%2F3-540-51084-2_2) によって提唱されました。

Ada や Scheme が初期の、また有名な例として C++ の Standard Template Library (STL) が実装例として挙げられます。

実例を見ていきましょう。

例えば、スライスの順序を逆順に並び替える `Reverse` 関数を考えます。Generic Programming を使用しない、素朴な例であれば、以下に示すようにそれぞれの型ごとに実装を行う必要があります。

```go
func ReverseInts(s []Int) {
    f := 0
    l := len(s) - 1
    for f < l {
        s[f], s[l] = s[l], s[f]
        f++
        l--
    }
}

func ReverseStrings(s []string) {
    f := 0
    l := len(s) - 1
    for f < l {
        s[f], s[l] = s[l], s[f]
        f++
        l--
    }
}
```

これは手間です。型を定義するごとに同じようなロジックを書かなくてはいけません

そこで型を抽象化し、型に依存しないコードを書くことにします。

```go
func Reverse[T any](s []T) {
    f := 0
    l := len(s) - 1
    for f < l {
        s[f], s[l] := s[l], s[f]
        f++
        l--
    }
}
```

これで、 *全ての型のスライスで* 逆順に並び替える関数が使えるようになりました。
早速呼び出して ([Go Playground](https://go.dev/play/p/BVQfLf2b3nL)) みましょう。
期待通りに動くはずです。

```go:main.go
package main

import "fmt"

func Reverse[T any](s []T) {
    f := 0
    l := len(s) - 1
    for f < l {
        s[f], s[l] = s[l], s[f]
        f++
        l--
    }
}

type User struct {
  Name string
}

func main() {
  ints := []int{0,1,2,3,4,5,6,7,8}

  fmt.Println("ordered: ", ints)
  Reverse(ints)
  fmt.Println("reversed: ", ints)

  strings := []string{"apple", "grape", "orange", "banana"}

  fmt.Println("ordered: ", strings)
  Reverse(strings)
  fmt.Println("reversed: ", strings)

  users := []User{{"佐藤"},  {"鈴木"}, {"高橋"},  {"田中"}, {"伊藤"}}

  fmt.Println("ordered: ", users)
  Reverse(users)
  fmt.Println("reversed: ", users)
}
```

これが Generics の嬉しいところです。

# その他の機能との使い分け

Generics を使わなくても、Go 言語の他の機能を使用すれば目的の一部または全部を達成可能です。
とはいえ、デメリットもあるので、Generics が使えるようになった今、素直に Generics を使った方が良いでしょう。

## interface を駆使する

ingerface を駆使すればなんとかなります。実際に [sort.Sort](https://pkg.go.dev/sort#Sort) は sort できる interface である
[sort.Interface](https://pkg.go.dev/sort#Interface) を用意し、実装しています。ちなみに [sort.Reverse](https://pkg.go.dev/sort#Reverse) もあります。

一見、これだけでよく見えますが、sort できる interface を満たすように、各型に関数を定義する必要があります。

例えば、独自構造体で型を定義した `type User struct{}` のスライスで `sort.Sort` を使えるようにしたいのであれば、 `[]User` は `sort.Interface` を満たさなければなりません。
つまり、`Len()`, `Less(i, j int)`, `Swap(i, j int)` の実装がそれぞれで必要になり、あまり使いやすいとはいえないでしょう。

## reflect パッケージを使用する

reflect パッケージを使用すれば、 go のコードを非常に動的に扱え、任意の型のスライスで動く `Reverse` 関数を用意することもできるでしょう。

ただし、まずこの関数を正しく記述するのはかなり大変です。また、実行は遅くなり、静的な型チェックはできなくなります。

## コードジェネレータにより、自動的にコードを生成する

Go 言語のコード生成を使ってもゴールは達成できます。

例えば、型の一覧を `target.lst` とかに列挙し、そこから各 `Reverse` 関数を自動生成するプログラム `reverse_generator` を用意した上で
定義ファイル `reverse.go` に以下のように宣言し、コード生成をしてみるのも良いでしょう。

```go:reverse.go
//go:generate reverse_generator target.lst
```

これにより、`go build` すれば自動的にそれぞれの型向けのコードが生成されます。

しかし、この手法は、参照するパッケージが増えるごとの毎回ビルドのし直しが走りますし、多分とても扱いにくいです。

# Generics の基本的な文法

文法もアップデートされるので、こればかりは公式ドキュメントを参照した方が良いでしょう。

そんなわけで [Tutorial: Getting started with generics](https://go.dev/doc/tutorial/generics) へのリンクを貼り、本文書を閉じたいと思います。
