---
title: 'Go 言語でのコマンドライン引数処理'
date: '2022-07-23'
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

# コマンドライン引数を得る - os.Args

コマンドライン引数は [os.Args](https://golang.org/pkg/os/#pkg-variables) から参照できます。

`os.Args` にはプログラム名および実行時の引数がスライスの形で保持されます。

サンプルプログラムから実行例を見ていきましょう。単純に `os.Args` を標準出力に出力するプログラムを用意しました。

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

# オプションと引数を解析する - flag パッケージ

オプションと引数を解析するには標準ライブラリの [flag](https://golang.org/pkg/flag/) パッケージを用います。
もちろん、 `os.Args` を自分で解析しても良いですが、ライブラリを用いた方が楽でしょう。

## 基本的な使い方

最も基本的な流れは以下の通りです。

1. プログラム中で読み取りたいオプションを定義する
2. `flag.Parse()` を呼び出し、コマンドライン引数を解析し、変数に割り当てる　

基本的な使い方を説明するために、

* `--flagname` という数値を読み取るオプション
* `--ip` という文字列を読み取るオプション

の 2 つを定義した[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/basic/main.go) をみていきましょう。

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	// オプションを宣言する
	// 名前は flagname で、数値。例えば、 --flagname 2525 のようになる
	// デフォルト値は 1234 とする
	// オプションの使用方法として "help message for flagname" を記述しておく
	var ip = flag.Int("flagname", 1234, "help message for flagname")

	// 与えられた引数をパースする
	// ここでは `ip` に `--flagname` で与えられた数値をセットする
	flag.Parse()
	fmt.Println("ip has value ", *ip)
}
```

13 行目の `flag.Int` で、数値を受け取るオプション `--flagname` を定義しています。
また、このオプションで指定された数値が変数 `var ip` に入力される様に定義しています。

17 行目で `flag.Parse` を呼び出し、具体的にユーザがプログラム実行時に入力したコマンドライン引数を解析しています。
このタイミングで、変数 `ip` に引数をセットします。

このコードを実行してみましょう。
実行するときに、もちろんオプションを指定して実行してみます。
以下の様に実行します。

```
$ go run main.go --flagname 2525
ip has value 2525

$ go build -o main main.go
$ ./main --flagname 2525
ip has value 2525
```

きちんと、コマンドライン引数が処理されているのがわかるかと思います。

## オプションを定義し、値を読み取るるためのポインタを受け取る

コマンドライン引数を定義し、入力された値を読み取るポインタを設定するには引数の型に応じて
[Bool](https://pkg.go.dev/flag#Bool)
[Int](https://pkg.go.dev/flag#Int)
[Int64](https://pkg.go.dev/flag#Int64)
[Uint](https://pkg.go.dev/flag#Uint)
[Uint64](https://pkg.go.dev/flag#Uint64)
[Float64](https://pkg.go.dev/flag#Float64)
[String](https://pkg.go.dev/flag#String)
[Duration](https://pkg.go.dev/flag#Duration)
を使用します。

これらの関数は、第1引数としてオプション名、第2引数にデフォルト値を、第3引数にヘルプメッセージを指定します。
関数の返り値として、オプションをパースした際に値が設定される変数の *ポインタ* が返されます。
`flag.Parse()` を呼び出すことで、コマンドライン引数がパースされてポインタの示す値が更新されます。

[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/non_vars/main.go) を見てみましょう。

```
package main

import (
	"flag"
	"fmt"
)

func main() {
  // 各種オプションを定義する
	var flagBool = flag.Bool("bool-flag", false, "usage message for flag.Bool")
	var flagInt = flag.Int("int-flag", 0, "usage message for flag.Int")
	var flagInt64 = flag.Int64("int64-flag", 0, "usage message for flag.Int64")
	var flagUint = flag.Uint("uint-flag", 0, "usage message for flag.Uint")
	var flagUint64 = flag.Uint64("uint64-flag", 0, "usage message for flag.Uint64")
	var flagFloat64 = flag.Float64("float64-flag", 0, "usage message for flag.Float64")
	var flagString = flag.String("string-flag", "", "usage message for flag.String")
	var flagDuration = flag.Duration("duration-flag", 0, "usage message for flag.Duration")

  // この段階では、ポインタが示す値はデフォルト値となっています。

	flag.Parse()

  // flag.Parse() を呼び出すことでコマンドライン引数が処理されポインタがさす値が更新されます

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

オプションが定義できたので、プログラムの実行時に定義したオプションを呼び出すことができます。

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

## オプションを定義し、事前に宣言した変数に紐付ける

オプション定義時にポインタを受け取るのではなく、予め宣言した変数を元にオプションを定義することもできます。

[BoolVar](https://pkg.go.dev/flag#BoolVar)
[IntVar](https://pkg.go.dev/flag#IntVar)
[Int64Var](https://pkg.go.dev/flag#Int64Var)
[UintVar](https://pkg.go.dev/flag#UintVar)
[Uint64Var](https://pkg.go.dev/flag#Uint64Var)
[Float64Var](https://pkg.go.dev/flag#Float64Var)
[StringVar](https://pkg.go.dev/flag#StringVar)
[DurationVar](https://pkg.go.dev/flag#DurationVar)
を用いてオプションの定義をします。

[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/vars/main.go)

```
package main

import (
	"flag"
	"fmt"
	"time"
)

func main() {

  // 事前に変数を宣言しておきます

	var flagBoolVar bool
	var flagIntVar int
	var flagInt64Var int64
	var flagUintVar uint
	var flagUint64Var uint64
	var flagFloat64Var float64
	var flagStringVar string
	var flagDurationVar time.Duration

  // オプションを定義し、宣言済みの変数を割り当てます

	flag.BoolVar(&flagBoolVar, "bool-var-flag", false, "usage message for flag.Bool")
	flag.IntVar(&flagIntVar, "int-var-flag", 0, "usage message for flag.Int")
	flag.Int64Var(&flagInt64Var, "int64-var-flag", 0, "usage message for flag.Int64")
	flag.UintVar(&flagUintVar, "uint-var-flag", 0, "usage message for flag.Uint")
	flag.Uint64Var(&flagUint64Var, "uint64-var-flag", 0, "usage message for flag.Uint64")
	flag.Float64Var(&flagFloat64Var, "float64-var-flag", 0, "usage message for flag.Float64")
	flag.StringVar(&flagStringVar, "string-var-flag", "", "usage message for flag.String")
	flag.DurationVar(&flagDurationVar, "duration-var-flag", 0, "usage message for flag.Duration")

  // この段階では、変数の値はデフォルト値となっています。

	flag.Parse()

  // flag.Parse() を呼び出すことでコマンドライン引数が処理され変数の値が更新されます

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

オプションが定義できたので、プログラムの実行時に定義したオプションを呼び出すことができます。

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

## オプションの設定先に独自の型 (構造体や取れる値に制限をかける場合など) を用いる - Value interface

TODO: ここは曜日 enum をとるオプションとかみたいな、実践例で説明する

さらに細かい制御を行いたい場合として、 [Value](https://pkg.go.dev/flag#Value) interface を実装した型を用意し、 `flag.Var()` を呼び出すことで細かな動きを実装できます

具体的には、自前の型が `String()` と `Set()` を実装しているとき、 `flag.Var()` に割り当てられるようになります。

以下が [サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/value_interface/main.go) です。

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
// Set() 関数は flag.Parse が実際のオプションをこの変数に割り当てるために使われます
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

flag パッケージでは同じ変数を複数のオプションに割り当て可能です。
これを利用することで、同じオプションに対して long オプションと short オプションを定義することができます。
例えば、 `-f` と `--filename` の２つの同じオプションを定義することができます。

同じ変数を使う場合、初期値の割り当て順序は *未定義* です。ですので、同じ初期値を用いるようにしましょう。

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/two_flags/main.go)です。

ただし、この手法ではヘルプメッセージがあまりうまく定義できません。

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

## -v, -vv, -vvv, -vvvv のように、v の数で出力レベルを切り替えられるオプションを定義する

`ssh` コマンドなどでは、`-v`, `-vv` と v を重ねることで出力レベルを切り替えることができます。
これを `flag` パッケージで実現するためには、個別にオプションを定義し、個別に出力レベルを取得する関数を定義するのが良いでしょう。

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/verbose_option/main.go)です。

ただし、この手法ではヘルプメッセージがあまりうまく定義できません。

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	v1 := flag.Bool("v", false, "usage")
	v2 := flag.Bool("vv", false, "usage")
	v3 := flag.Bool("vvv", false, "usage")
	v4 := flag.Bool("vvvv", false, "usage")
	v5 := flag.Bool("vvvvv", false, "usage")

  flag.Parse()

	vLv := getVerboseLevel(*v1, *v2, *v3, *v4, *v5)

	fmt.Printf("verbose level is %d\n", vLv)
}

func getVerboseLevel(v ...bool) int {
	cnt := 0
	for idx, i := range v {
		if i {
			cnt = idx + 1
		}
	}
	return cnt
}
```

```
$ go run main.go
verbose level is 0
$ go run main.go -vv
verbose level is 2
$ go run main.go -vvvv
verbose level is 4
```

## 引数を受け取る - Args

定義したオプション以外の値として、引数を取得するために [Arg](https://pkg.go.dev/flag#Arg), [Args](https://pkg.go.dev/flag#Args) が、
個数を取るために [NArg](https://pkg.go.dev/flag#NArg) が用意されています。

引数は、オプションの後に指定された値です。ですので、例えば `-n` というオプションを定義したプログラムでは以下のように処理されます

| コマンドライン引数 | オプション | 引数 (Args で取得可能な値) |
| `-n 47 foo bar` | `-n 47` | `foo bar` |
| `foo` | - | `foo` |
| `foo -n 47` | - | `foo -n 47` |

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/args/main.go)です。

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	var nFlag = flag.Int("n", 1234, "help message for flagname")

	flag.Parse()
	fmt.Printf("arguments num: %d\n", flag.NArg())

	fmt.Printf("arguments as []string: %v\n", flag.Args())

	fmt.Println("each arguments")
	for i, j := 0, flag.NArg(); i < j; i++ {
		fmt.Printf("\targument %d: %s\n", i, flag.Arg(i))
	}
	fmt.Printf("n sets %d\n", *nFlag)
}
```

```
$ go run main.go -n 47 arg1 arg2
arguments num: 2
arguments as []string: [arg1 arg2]
each arguments
        argument 0: arg1
        argument 1: arg2
n sets 47
```

オプションの後は引数として扱われるので、以下のようにコマンドライン引数を指定した場合は `-n 47` がオプションではなく引数として扱われます。
そのため、定義したオプションはデフォルト値のままとなります。


```
$ go run main.go arg1 -n 47 arg2
arguments num: 4
arguments as []string: [arg1 -n 47 arg2]
each arguments
        argument 0: arg1
        argument 1: -n
        argument 2: 47
        argument 3: arg2
n sets 1234
```

## サブコマンドを定義する - NewFlagSet()

サブコマンドは引数をさらに処理することで実現可能です。

[FlagSet](https://pkg.go.dev/flag#FlagSet) 構造体が用意されており、
定義したオプションはこの型の定義済み変数 [CommandLine](https://pkg.go.dev/flag#pkg-variables) に保存されます。

同様に、サブコマンド用の `FlagSet` を宣言し、親コマンドの引数をこの `FlagSet` でパースすることで、サブコマンドのオプションを処理することができます。

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/flag_set/main.go)です。

```
package main

import (
	"flag"
	"fmt"
)

func main() {

	// 親コマンド向けの引数を定義する
	rf := flag.String("rootFlag", "default var", "usage of root flag")


	// サブコマンド用の変数セットを作成し、引数 --subFlag を定義する
	sub := flag.NewFlagSet("sub", flag.ExitOnError)
	sf := sub.String("subFlag", "default var", "usage message")

	flag.Parse()

	// 引数の１番目をサブコマンドとして取得する
	// 特にサブコマンドが指定されずにプログラムが呼び出された場合、subCmd は空文字になります
	subCmd := flag.Arg(0)

	switch subCmd {
	case "sub":
		// flag.Args() 自体には "sub" が最初に入ってしまうので使えない
		// なので、最初の１つを取り除いた [1:] をサブコマンドの FlagSet に Parse 関数で渡す
		// flag.Arg(0) があることで、len(flag.Args()) > 0 は自明
		sub.Parse(flag.Args()[1:])
	default:
		// noop
	}

	fmt.Printf("rootFlag is %s\n", *rf)
	fmt.Printf("root arguments as []string: %v\n", flag.Args())
	fmt.Printf("subFlag is %s\n", *sf)
	fmt.Printf("sub arguments as []string: %v\n", sub.Args())
}
```

このプログラムを呼び出した結果は以下のようになります

```
$ go run main.go --rootFlag foofoo sub --subFlag barbar arg1 arg2
rootFlag is foofoo
root arguments as []string: [sub --subFlag barbar arg1 arg2]
subFlag is barbar
sub arguments as []string: [arg1 arg2]
```

`FlagSet` を新しく作成する際には [NewFlagSet](https://pkg.go.dev/flag#NewFlagSet) を用います。
第1引数には FlagSet 名を指定します。この名前は、デフォルトのヘルプメッセージや、エラーメッセージで用いられます。

```
$ go run main.go sub --help
Usage of sub:
  -subFlag string
        usage message (default "default var")
```

第2引数にはエラー時の挙動を表した定数を指定します。
エラー時の挙動を表した定数については「存在しないフラグなどが指定されたエラー時の挙動を変更する - ErrorHandling」にて解説します。

## ヘルプメッセージを表示する - PrintDefaults()

[PrintDefaults](https://pkg.go.dev/flag#PrintDefaults) を使うと、定義したオプションをもとにヘルプメッセージを標準エラーに出力することができます。

メッセージの出力先を標準エラー以外にしたい場合は、 [CommandLine.SetOutput](https://pkg.go.dev/flag#FlagSet.SetOutput) を呼び出すことで変更可能です。

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/print_default/main.go)です。

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

	// 定義した各オプションの、usage を表示します
	flag.PrintDefaults()
}

```

```
$ go run main.go
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

組み込みのヘルプメッセージではなく、オリジナルのヘルプメッセージを表示したい場合は定義済み変数 [Usage](https://pkg.go.dev/flag#pkg-constants) を書き換えます

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/usage/main.go)です。

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
this is custom message
```

## 存在しないフラグなどが指定されたエラー時の挙動を変更する - ErrorHandling

`FlagSet` を新しく作成する際に用いる [NewFlagSet](https://pkg.go.dev/flag#NewFlagSet) の第2引数はエラー時の挙動を表す [ErrorHandling](https://pkg.go.dev/flag#ErrorHandling) です。

この値を変更することでオプションの処理時 (`flag.Parse()` を呼び出した時) のエラー、
例えば存在しないオプションが指定されていた場合や、 `Var` で定義したオプションの `Set()` 中でエラーが起きた場合などの挙動を変更できます。

なお、 `-h`, `--help` が指定されてプログラムを呼び出され、さらにこれらのオプションを定義していなかった場合、 `flag.Parse()` は特殊なエラー
[ErrHelp](https://pkg.go.dev/flag#pkg-variables) を発生させ、この `FlagSet` で設定されている動作に従います

`ContinueOnError`, `ExitOnError` または `PanicOnError` のいずれかから選択でき、それぞれ以下のような挙動になります。

* `ContinueOnError`: エラー発生時にも処理を継続します
* `ExitOnError`: エラー発生時に `os.Exit(2)` を呼び出し、エラー終了します。または、`-h`, `--help` オプションが指定されていた場合は `os.Exit(0)` でプログラムを終了します
* `PanicOnError`; エラー発生時にパニックでプログラムを終了します

定義済み変数 `CommandLine` の errorHandling は `ExitOnError` に設定されており、基本的には変更できません
...が、もし変更したい場合は `CommandLine.Init()` を呼び出すことで無理やり変更できます。

以下が[サンプルコード](https://github.com/ayasuda/sandbox/blob/master/go/flag/err_exit/main.go)です。

```
package main

import (
	"flag"
	"fmt"
)

func main() {
	flag.Int("sample", 0, "default usage message")

	// Init を呼び出すことで errorHandling が変更できる
	// しかし、CommandLine はデフォルトで ExitOnError が指定されているのでコメントアウトする
	// flag.CommandLine.Init(os.Arg[0], flag.ExitOnError)

	flag.Parse()
	fmt.Println("This line should not be printed if -h, --help added or some error happened")
}
```

当たり前ではありますが、特段エラーが発生しない場合は処理は継続します

```
$ go run main.go --sample 47
This line should not be printed if -h, --help added or some error happened
```

`-h`, `--help` などが指定され、しかし未定義の場合は `ErrHelp` が発生し、ヘルプメッセージが出力されます。
その後、設定された `ExitOnError` に基づきプログラムは終了します。

なので、 "This line should..." は表示されません。

```
$ go run main.go -h
Usage of main:
  -sample int
        default usage message
```

存在しないオプションを指定した場合、その旨を示すエラーメッセージとヘルプメッセージが出力されます。
その後、設定された `ExitOnError` に基づきプログラムは終了します。
また、このエラーは `ErrHelp` ではないのでプログラムは Exit(2) で終了します。

なので、 "This line should..." は表示されません。

```
$ go run main.go --not-defined
flag provided but not defined: -not-defined
Usage of main:
  -sample int
        default usage message
exit status 2
```

## オプションのテスト

`flagSet` または `flag.CommandLine` の `Parse()` に配列を渡すことでテストが可能です。
テスト前に `Init()` などでエラー時の挙動を変更しておく必要があります。

とはいえ、余程特殊なことをしていない限りはオプションのテストは不要でしょう。

flag パッケージ自身はテストされていますし、あくまでも開発者はオプションの定義をするのみに使用を留めた方が良いかと思います。
