---
title: '改めて flag パッケージの使い方 - golang flag'
date: '2119-07-19'
description: '改めて、自分のために golang の標準パッケージである flag の使い方をまとめておきます。'
keywords:
  - golang
  - flag
  - command-line
  - arg
---

Go 言語では標準パッケージの中にコマンドライン引数をパースする [flag](https://golang.org/pkg/flag/) があります。

本記事では、改めて使い方をまとめてみます。

一番簡単な使い方

```go:basic.go
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
