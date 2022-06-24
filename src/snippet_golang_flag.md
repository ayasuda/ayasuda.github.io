---
title: 'Go 言語でのコマンドライン引数処理'
date: '2119-07-19'
description: 'Go 言語でコマンドライン引数を受け取り、適宜処理する方法についてサンプルコードともにまとめました'
tags:
  - Go
keywords:
  - Go
  - Args
  - flag
  - コマンドライン引数
---

コマンドライン引数処理とは何か？　については [コマンドライン引数処理ことはじめ](/what_is_command_line_argument) にてまとめました。
ここでは、 Go 言語でコマンドライン引数処理をどのようにやるのかについてまとめていきます。

# os.Args

最も簡単にコマンドライン引数を処理するのであれば [os.Args](https://golang.org/pkg/os/#pkg-variables) 変数がわかりやすいでしょう。

`os.Args` にはプログラム名および実行時の引数がスライスの形で保持されています。

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

以下のようにプログラムをビルドして実行できます。

```
$ go build args.go
$ ./args foo bar --baz "qux"
```

プログラムを実行すると、実行時に呼び出したプログラム名、引数が表示されます。

```
[./args foo bar --baz qux]
```

ご覧の通り、呼び出した時のプログラム名と引数がシンプルにそのまま表示されました。

# flag パッケージ

`os.Args` はあまりにもシンプルすぎて実用上ではもう少し簡単にコマンドライン引数を扱いたいです。
Go 言語では標準パッケージの中にコマンドライン引数をパースする [flag](https://golang.org/pkg/flag/) があります。
以下、 flag パッケージを使った場合のコマンドライン引数の取り扱いについて見てみましょう。

## 基本的な使い方

最も基本的な流れは以下の通りです。

1. サポートするフラグを定義する
2. `flag.Parse()` を呼び出し、コマンドライン引数を解析し、変数に割り当てる　

まずはサンプルコード ([github](https://github.com/ayasuda/sandbox/blob/master/go/flag/basic/main.go) にアップロード済み) をみてみましょう。

```go:flag.go
package main

import (
	"flag"
	"fmt"
)

func main() {
	// フラグを宣言する
	// 名前は flagname で、数値。例えば、 --flagname 2525 のようになる
	// デフォルト値は 1234 とする
	// フラグの使用方法として "help message for flagname" を記述しておく
	var ip = flag.Int("flagname", 1234, "help message for flagname")

	// 与えられた引数をパースする
	// ここでは `ip` に `--flagname` で与えられた数値をセットする
	flag.Parse()
	fmt.Println("ip has value ", *ip)
}
```

13 行目の `flag.Int` で、数値を受け取るフラグ `--flagname` を定義しています。
また、このフラグで指定された数値が変数 `var ip` に入力される様に定義しています。

17 行目で `flag.Parse` を呼び出し、具体的にユーザがプログラム実行時に入力したコマンドライン引数を解析しています。
このタイミングで、変数 `ip` に引数をセットします。

このコードを実行してみましょう。
実行するときに、もちろんフラグを指定して実行してみます。
以下の様に実行します。

```
$ go run main.go --flagname 2525
ip has value 2525

$ go build -o main main.go
$ ./main --flagname 2525
ip has value 2525
```

きちんと、コマンドライン引数が処理されているのがわかるかと思います。

## フラグを定義する (ポインタを受け取る)

tbd;
([github](https://github.com/ayasuda/sandbox/blob/master/go/flag/non_vars/main.go) にアップロード済み)

```
package main

import (
	"flag"
	"fmt"
)

func main() {
	var flagBool = flag.Bool("bool-flag", false, "usage message for flag.Bool")
	var flagInt = flag.Int("int-flag", 0, "usage message for flag.Int")
	var flagInt64 = flag.Int64("int64-flag", 0, "usage message for flag.Int64")
	var flagUint = flag.Uint("uint-flag", 0, "usage message for flag.Uint")
	var flagUint64 = flag.Uint64("uint64-flag", 0, "usage message for flag.Uint64")
	var flagFloat64 = flag.Float64("float64-flag", 0, "usage message for flag.Float64")
	var flagString = flag.String("string-flag", "", "usage message for flag.String")
	var flagDuration = flag.Duration("duration-flag", 0, "usage message for flag.Duration")

	flag.Parse()
	fmt.Printf("bool-flag has value %t\n", *flagBool)
	fmt.Printf("int-flag has value %d\n", *flagInt)
	fmt.Printf("int64-flag has value %d\n", *flagInt64)
	fmt.Printf("uint-flag has value %d\n", *flagUint)
	fmt.Printf("uint64-flag has value %d\n", *flagUint64)
	fmt.Printf("float64-flag has value %f\n", *flagFloat64)
	fmt.Printf("string-flag has value '%s'\n", *flagString)
	fmt.Printf("duration-flag has value %d\n", *flagDuration)
}
```

tbd;


```
$ go run main.go \
  --bool-flag \
  --int-flag 47 \
  --int64-flag 53 \
  --uint-flag 59 \
  --uint64-flag 61 \
  --float64-flag 3.14 \
  --string-flag "foobar" \
  --duration-flag 12h34m56s
bool-flag has value true
int-flag has value 47
int64-flag has value 53
uint-flag has value 59
uint64-flag has value 61
float64-flag has value 3.140000
string-flag has value 'foobar'
duration-flag has value 45296000000000
```

## フラグを定義する (設定先の変数を指定する)

([github](https://github.com/ayasuda/sandbox/blob/master/go/flag/vars/main.go) にアップロード済み)

```
package main

import (
	"flag"
	"fmt"
	"time"
)

func main() {
	var flagBoolVar bool
	var flagIntVar int
	var flagInt64Var int64
	var flagUintVar uint
	var flagUint64Var uint64
	var flagFloat64Var float64
	var flagStringVar string
	var flagDurationVar time.Duration

	flag.BoolVar(&flagBoolVar, "bool-var-flag", false, "usage message for flag.Bool")
	flag.IntVar(&flagIntVar, "int-var-flag", 0, "usage message for flag.Int")
	flag.Int64Var(&flagInt64Var, "int64-var-flag", 0, "usage message for flag.Int64")
	flag.UintVar(&flagUintVar, "uint-var-flag", 0, "usage message for flag.Uint")
	flag.Uint64Var(&flagUint64Var, "uint64-var-flag", 0, "usage message for flag.Uint64")
	flag.Float64Var(&flagFloat64Var, "float64-var-flag", 0, "usage message for flag.Float64")
	flag.StringVar(&flagStringVar, "string-var-flag", "", "usage message for flag.String")
	flag.DurationVar(&flagDurationVar, "duration-var-flag", 0, "usage message for flag.Duration")

	flag.Parse()
	fmt.Printf("bool-var-flag has value %t\n", flagBoolVar)
	fmt.Printf("int-var-flag has value %d\n", flagIntVar)
	fmt.Printf("int64-var-flag has value %d\n", flagInt64Var)
	fmt.Printf("uint-var-flag has value %d\n", flagUintVar)
	fmt.Printf("uint64-var-flag has value %d\n", flagUint64Var)
	fmt.Printf("float64-var-flag has value %f\n", flagFloat64Var)
	fmt.Printf("string-var-flag has value '%s'\n", flagStringVar)
	fmt.Printf("duration-var-flag has value %d\n", flagDurationVar)
}

```

```
$ go run main.go \
  --bool-var-flag \
  --int-var-flag 47 \
  --int64-var-flag 53 \
  --uint-var-flag 59 \
  --uint64-var-flag 61 \
  --float64-var-flag 3.14 \
  --string-var-flag "foobar" \
  --duration-var-flag 12h34m56s
bool-var-flag has value true
int-var-flag has value 47
int64-var-flag has value 53
uint-var-flag has value 59
uint64-var-flag has value 61
float64-var-flag has value 3.140000
string-var-flag has value 'foobar'
duration-var-flag has value 45296000000000
```

## フラグの設定先に独自の型を用いる - Value interface

さらに細かい制御を行いたい場合として、 [Value](https://pkg.go.dev/flag#Value) interface を実装した型を用意し、 `flag.Var()` を呼び出すことで細かな動きを実装できます

具体的には、自前の型が `String()` と `Set()` を実装しているとき、 `flag.Var()` に割り当てられるようになります。

以下がサンプルコードです。
([github](https://github.com/ayasuda/sandbox/blob/master/go/flag/value_interface/main.go) にアップロード済み)

```go:flag.go
package main

import (
	"flag"
	"fmt"
)

type Foo {
	Attr string
}

// Value interface を満たすために String() を実装する
// String() 関数はプログラム診断などのために使います
func (f Foo) String() string {
	return f.Attr
}

// Value interface を満たすために Set() を実装する
// Set() 関数は flag.Parse が実際のフラグをこの変数に割り当てるために使われます
func (f Foo) Set(s string) error {
	f.Attr = s
	return nil
}

func main() {
	var foo Foo
	flag.Var(&foo, "foo", "help message")
	flag.Parse()
	fmt.Println("foo is ", foo)
}
```

```
$ go run main.go --foo bar
foo is bar
```

## long オプションと short オプションを定義する

flag パッケージでは同じ変数を複数のフラグに割り当て可能です。
これを利用することで、同じフラグに対して long オプションと short オプションを定義することができます。

同じ変数を使う場合、初期値の割り当て順序は *未定義* です。ですので、同じ初期値を用いるようにしましょう。

以下がサンプルコードです。
([github](https://github.com/ayasuda/sandbox/blob/master/go/flag/two_flags/main.go) にアップロード済み)

```go:flag.go
package main

import (
	"flag"
	"fmt"
)

func main() {
	const (
		default = "default value"
		usage   = "usage message"
	)

	var option string
  // short オプションとして `-f` を定義する
	flag.StringVar(&option, "f", default, usage)
  // long オプションとして `--flagname` を定義する
	flag.StringVar(&option, "flagname", default, usage)

	flag.Parse()
	fmt.Println("option is", option)
}
```

```
$ go run main.go --flagname foo
option is foo
$ go run main.go -f bar
option is bar
```

## サブコマンドを定義する - NewFlagSet()


## ヘルプメッセージを表示する - PrintDefaults()

`PrintDefaults()` を使うと、定義したフラグをもとにヘルプメッセージを標準エラーに出力することができます。

```
package main

import (
	"flag"
	"time"
)

func main() {
	var _ = flag.Bool("bool-flag", false, "usage message for flag.Bool")
	var _ = flag.Int("int-flag", 0, "usage message for flag.Int")
	var _ = flag.Int64("int64-flag", 0, "usage message for flag.Int64")
	var _ = flag.Uint("uint-flag", 0, "usage message for flag.Uint")
	var _ = flag.Uint64("uint64-flag", 0, "usage message for flag.Uint64")
	var _ = flag.Float64("float64-flag", 0, "usage message for flag.Float64")
	var _ = flag.String("string-flag", "", "usage message for flag.String")
	var _ = flag.Duration("duration-flag", 0, "usage message for flag.Duration")

	var flagBoolVar bool
	var flagIntVar int
	var flagInt64Var int64
	var flagUintVar uint
	var flagUint64Var uint64
	var flagFloat64Var float64
	var flagStringVar string
	var flagDurationVar time.Duration
	flag.BoolVar(&flagBoolVar, "bool-var-flag", false, "usage message for flag.Bool")
	flag.IntVar(&flagIntVar, "int-var-flag", 0, "usage message for flag.Int")
	flag.Int64Var(&flagInt64Var, "int64-var-flag", 0, "usage message for flag.Int64")
	flag.UintVar(&flagUintVar, "uint-var-flag", 0, "usage message for flag.Uint")
	flag.Uint64Var(&flagUint64Var, "uint64-var-flag", 0, "usage message for flag.Uint64")
	flag.Float64Var(&flagFloat64Var, "float64-var-flag", 0, "usage message for flag.Float64")
	flag.StringVar(&flagStringVar, "string-var-flag", "", "usage message for flag.String")
	flag.DurationVar(&flagDurationVar, "duration-var-flag", 0, "usage message for flag.Duration")

	// 定義した各フラグの、usage を表示します
	flag.PrintDefaults()
}

```

```
$ go run main.go                                                                                                              (master)
  -bool-flag
        usage message for flag.Bool
  -bool-var-flag
        usage message for flag.Bool
  -duration-flag duration
        usage message for flag.Duration
  -duration-var-flag duration
        usage message for flag.Duration
  -float64-flag float
        usage message for flag.Float64
  -float64-var-flag float
        usage message for flag.Float64
  -int-flag int
        usage message for flag.Int
  -int-var-flag int
        usage message for flag.Int
  -int64-flag int
        usage message for flag.Int64
  -int64-var-flag int
        usage message for flag.Int64
  -string-flag string
        usage message for flag.String
  -string-var-flag string
        usage message for flag.String
  -uint-flag uint
        usage message for flag.Uint
  -uint-var-flag uint
        usage message for flag.Uint
  -uint64-flag uint
        usage message for flag.Uint64
  -uint64-var-flag uint
        usage message for flag.Uint64
```

## オリジナルのヘルプメッセージを表示する - Usage

```
package main

import (
	"flag"
	"fmt"
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "this is custom message\n")
	}
	flag.Parse()
}
```

```
$ go run main.go --help
thit
is custom message
```

## help エラーの取り扱い

## CommandLine

## -v, -vv, -vvv, -vvvv

結論から言うと、個別にフラグを定義するのが一番楽

## メインコマンド + フラグ + サブコマンド + フラグ

例えば `git` コマンドでは、メインとなるコマンド自体へのフラグと、サブコマンドへのフラグを同時に指定できます。

```
$ git -C /path/to/repo log --pretty=oneline
```

メインコマンド、サブコマンド用の FlagSet を作る。
親用はエラーハンドリングを無視にする
親用でパースして、args の長さを見る。
あまりをサブコマンドに渡す

コマンド定義を Struct でやる。取得は個別に関数定義する。


## フラグのテスト

flag.Parse に配列を渡せばテストできる

https://gist.github.com/shogo82148/9c22369981779155b399
