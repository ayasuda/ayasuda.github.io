---
title: 'go doc の使い方・コメントを書いて、ちゃんと読む'
date: '2019-04-12'
description: 'godoc コマンドを使ってドキュメントを読む方法についてまとめてみました'
tags:
  - Go
  - Tools
keywords:
  - Go
  - Tools
  - Command
  - godoc
---

Go 言語ではソースコード中にコメントを書くことで自動的に API ドキュメントを生成する方法が最初からサポートされています。

[Godoc: documenting Go code](https://blog.golang.org/godoc-documenting-go-code) でも、

> The Go project takes documentation seriously.

と書かれているほど、しっかりと練られた文書化ツールが揃っています。

とはいえ、良い書き方や読み方がわからないと、書く気が起きませんよね？
そんなわけで、本文書では文書生成用のドキュメントの書き方と、それぞれのドキュメントの読み方について記していきます。

# godoc の動きの確認

まず、サンプルコードを用意しましょう。

```
$ mkdir -p $GOPATH/src/path/to/your/library
$ cd $GOPATH/src/path/to/youre/library
$ vim sample.go
```

```go:sample.go
package sample

import "fmt"

func Foo(s string) string {
	return "Foo " + s + " ooF"
}

func PrintFoo(s string) {
	fmt.Println(Foo(s))
}
```

*この段階で、すでに `godoc` コマンドからドキュメントを参照可能です*

まずはブラウザから見てみましょう。`-http` オプションで、ドキュメントをみるための web サーバが起動できます。

```
$ godoc -http=:8080
```

コマンドを実行したら `http://localhost:8080` にアクセスしてみましょう。まるで公式サイトのような Web ページが見られると思います。

![](/img/introduction_go_doc/1.png)

ヘッダの「Packages」リンクから、標準ライブラリおよび、*GOPATH に持ってきている全てのパッケージのドキュメント* が確認できます。
もちろん、たった今作った `sample.Foo` のドキュメントもあります！

![](/img/introduction_go_doc/2.png)

なお、この時の URL は `http://localhost:600/pkg/path/to/your/library/` になります。わかりやすいですね！

![](/img/introduction_go_doc/3.png)

# 簡単なコメントを書く

Godoc で読むためのコメントはとてもシンプルで、`godoc` がなくても読みたくなるようなコメントが書けるように意識して書くのが良いでしょう。Go Blog でも以下のように言及されています。

> Godoc comments are just good comments, the sort you would want to read even if godoc didn't exist.

コメントは `type`, `variable`, `constant`, `function`, `package` に書くことができます。また、コメントには一つルールがあり、その要素名で始める必要があります。

```go:sample.go
// sample パッケージはコメントの書き方と読み方の例を提供します。
package sample

import "fmt"

// Bar はとある変数です
var Bar = "some variable"

// Baz はとある定数です
const Baz = "some constant"

// Qux はとある構造体です
type Qux struct {
	// A には適当な文字列をどうぞ
	A string
	// A にも適当な文字列をどうぞ
	B string
}

// Foo はとりあえず前後に変な文字をくっけます
func Foo(s string) string {
	return "Foo " + s + " ooF"
}

// PrintFoo はとりあえず前後に変な文字をくっけます
func PrintFoo(s string) {
	fmt.Println(Foo(s))
}
```

こいつをブラウザで表示すると下記のようにいい感じに表示されます。

![](/img/introduction_go_doc/4.png)

# ブラウザ以外からドキュメントを読む

`godoc` のヘルプを見ればすぐにわかりますが、`godoc package [name]` でそのパッケージおよび各種項目のドキュメントがコマンドラインから読めます。

```
$ godoc fmt Println
func Println(a ...interface{}) (n int, err error)
    Println formats using the default formats for its operands and writes to
    standard output. Spaces are always added between operands and a newline
    is appended. It returns the number of bytes written and any write error
    encountered.
```

自作のライブラリ含めたサードパーティのライブラリのドキュメントを読む場合は、パッケージをフルパスで書きましょう。先に作ったサンプルの場合なら次のようになります。

```
godoc path/to/your/library PrintFoo
func PrintFoo(s string)
    PrintFoo はとりあえず前後に変な文字をくっけます
```

> *Q: パッケージ名の `sample` はどこに行ったのでしょうか？*
>
> Answer: 僕がライブラリの作り方ミスって、sample が消失しただけだよ！ golang のライブラリの作り方はこの文書の範疇じゃないから仕方ないね！
> (具体的には、パッケージ名とディレクトリ名は通常一致させるべき)

# もっと詳しくドキュメントを書く

ここまでで日常使いには十分ですが、さらに詳しく、いろいろ書きたい人向けの機能にもふれておきましょう。

## パッケージドキュメントを盛り盛りにする

専門知識が必要なパッケージを作りたいときなどに、プログラム本体のコメントとしてドキュメントを書くとちょっと長くなるケースがあると思います。
そういう時はパッケージドキュメント専用のファイルを作ることができます。

具体的には、 `doc.go` というファイルを用意し、そこにパッケージのドキュメントを記述します。

[gob パッケージ](https://golang.org/pkg/encoding/gob/) では、この機能が使われており、ドキュメントは [src/encoding/gob/doc.go](https://golang.org/src/encoding/gob/doc.go) に書かれています。

## `-notes` オプションで追加項目をリストアップする

基本的にコード中や指定箇所以外のコメントは無視されますが、`godoc` のノート機能を使うと、より多くのメタ情報を知るせます。

デフォルトでは `BUG(who)` が定義されているので、例えば、下記のようなコメントを書くと、godoc で見たときにひとまとまりに表示されます。

```go
// Foo はとりあえず前後に変な文字をくっけます
//
// BUG(ayasuda) ごめん、なんかバグある気がする
func Foo(s string) string {
	return "Foo " + s + " ooF"
}
```

ブラウザで見ると下記のようになります。

![](/img/introduction_go_doc/5.png)

繰り返しになりますが、デフォルトでは `BUG` が定義されているので、コメント中で `BUG(who)` を記述可能です。`-notes` オプションでこの定義は自由に増やせます。

## 簡単なフォーマット

コメントを書く際に、以下のルールに従うとことで HTML 化した際のフォーマットを変更することができます。

* 連続した行は一つの段落と見なされます
  * 段落を区切りたい場合は空白行を間に入れる必要があります
* 英大文字で始まり、直前が句読点ではない単一行の段落は見出しになります
* 字下げすると整形済みテキストになります
* URL はリンクになります

そんなわけで、例えば、下記のようなコメントを書くと

```go
/*
ここはパッケージコメントの最初になるから見出しではないよー

Hで始まり単一行かつ句読点なしかつ前が見出しではないのでこれは見出し

段落段落
段落段落
段落段落

次の段落
次の段落

	整形済みテキスt

次のやつはリンクになるはず。
https://golang.org/
*/
package sample
```

以下のようにHTML化されます。

![](/img/introduction_go_doc/6.png)

これ以上にいろいろ装飾したい場合は、 最悪、ソースが [ここ](https://github.com/golang/tools/tree/master/godoc) にあるので・・・

## Example をつけるには

公式ドキュメントのいくつかの関数では、 Example が付いてます。
これは [Testable Examples](https://blog.golang.org/examples) を利用して作られています。

上記の `sample` パッケージに対して Testable Example を作るなら、まずは `/path/to/your/library/example_test.go` を用意します。
パッケージ名は `sample_test` としてください。

中には次のルールでサンプルがかけます。

```go
func ExampleFoo()     // Foo 関数のサンプルコードになります
func ExampleBar_Qux() // Bar 構造体の Qux 関数のサンプルコードになります
func Example()        // パッケージ全体のサンプルコードになります
func ExampleFoo_foo   // Foo 関数のサンプルコード(fooの場合)
```

また、テストコード中に `Output:` から始まるコメントを記載することで、標準出力に書き込まれた値をチェックすることができます。

そんなわけで、こんなコードを書きます。

```go:/path/to/your/library/example_test.go
package sample_test

import (
	"fmt"
	"path/to/your/library"
)

func ExampleFoo() {
	fmt.Println(sample.Foo("foo"))
	// Output: Foo foo ooF
}
```

テストはいつも通り、`go test` コマンドから実行可能です。

```
$ go test
PASS
ok  path/to/your/library  0.004s
```

後は、ドキュメントを生成すると、Example が記載されているはずです。

![](/img/introduction_go_doc/7.png)

# 参照

* [Godoc: documenting Go code - The Go Blog](https://blog.golang.org/godoc-documenting-go-code)
* [godoc - GoDoc](https://godoc.org/golang.org/x/tools/cmd/godoc)
* [Testable Examples in Go - The Go Blog](https://blog.golang.org/examples)

