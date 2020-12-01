---
title: 'Go 言語でのコマンドライン引数処理'
date: '2119-07-19'
description: '改めて、自分のために golang でのコマンドライン引数処理として os.Args と、標準パッケージである flag の使い方をまとめておきます。'
tags:
  - Go
keywords:
  - Go
  - Args
  - flag
  - コマンドライン引数
---

TODO: 前書き

# os.Args

[コマンドライン引数](https://en.wikipedia.org/wiki/Command-line_interface#Arguments) はプログラムの実行時にプログラムに渡す変数の一つです。

最も簡単にコマンドライン引数を処理するのであれば [os.Args](https://golang.org/pkg/os/#pkg-variables) 変数がわかりやすいでしょう。

プログラム名および実行時の引数がスライスの形で保持されています。

サンプルプログラム書いて動きを見て見ましょう。

```go:args.go
package main

import (
  "fmt"
  "os"
)

func main() {
  fmt.Println(os.Args)
}
```

このファイルをビルドし、実行して見ます。

```
$ go build args.go
$ ./args foo bar --baz "qux"
[./args foo bar --baz qux]
```

ご覧の通り、呼び出した時のプログラム名と引数がシンプルにそのまま表示されました。

# flag パッケージ

`os.Args` はあまりにもシンプルすぎて実用上ではもう少し簡単にコマンドライン引数を扱いたいです。

Go 言語では標準パッケージの中にコマンドライン引数をパースする [flag](https://golang.org/pkg/flag/) があります。

TODO: 以下言いまわし

一番簡単な使い方

```go:flag.go
package main

import (
	"flag"
	"fmt"
)

func main() {
	var ip = flag.Int("flagname", 1234, "help message for flagname")
	flag.Parse()
	fmt.Println("ip has value ", *ip)
}
```

実行方法

```
$ go run main.go --flagname 2525
ip has value 2525
$ go build -o main main.go
$ ./main --flagname 2525
ip has value 2525
```

フラグを宣言して
`flag.Parse` を実行して解析する


```
package main

import (
	"flag"
	"fmt"
)

func main() {
	var ip int
	flag.IntVar(&ip, "flagname", 1234, "help message for flagname")
	flag.Parse()
	fmt.Println("ip has value ", ip)
}
```

IntVar でバインドもできる


TOOD: 動作検証
```
package main

import (
	"flag"
	"fmt"
)

type Foo {
  Attr string
}

// TODO: Foo.Set, Foo.String の実装

func main() {
  var i Foo
  flag.Var(&i, "default value", "help message")
	flag.Parse()
	fmt.Println("i is ", i)
}
```

`flag.Value` インターフェースを実装することで、任意の struct をバインドできる

### long オプションと short オプション

## flag を使ったサブコマンドパターン

## メインコマンド + オプション + サブコマンド + オプション

例えば `git` コマンドでは、メインとなるコマンド自体へのオプションと、サブコマンドへのオプションを同時に指定できます。

```
$ git -C /path/to/repo log --pretty=oneline
```


メインコマンド、サブコマンド用の FlagSet を作る。
親用はエラーハンドリングを無視にする
親用でパースして、args の長さを見る。
あまりをサブコマンドに渡す
