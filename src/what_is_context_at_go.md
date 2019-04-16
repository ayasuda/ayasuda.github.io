---
title: 'Go 言語 context パッケージ誕生の背景と使用方法'
date: '2019-04-15'
description: 'サーバプログラムやAPI呼び出しなどをする際によく見かけることになる context パッケージ。このパッケージが何を解決たかったのかと、使用法についてまとめてみます。'
keywords:
  - Go
  - Context
  - How to
---

Go 言語を使って何を書くかといえば、なんだかんだでサーバプログラムを書くことが多いかと思います。

大抵の場合、ハンドラは goroutine で動かすことになります。また、ハンドラの中で goroutine 動かすケースも多々あります。
さて、例えばハンドラ内で外部 API を呼び出したり、マイクロサービスな関連サーバへリクエストをかけたりする際に、
それぞれのリクエストで AccessToken やタイムアウトの規定時間など、共通の値を用いるケースは多々あるかと思います。
また、 goroutine で平行で動かしているリクエストがある時、１つが失敗したら残りのリクエストも全部失敗させたいときなどもあり得るでしょう。

`context` パッケージはそのような、リクエスト毎のデータを取り扱うために作られました。

この文書は `context` パッケージの使い方とやりたかったことを
より初心者向けに、バカバカしく、何もかも忘却した２ヶ月後の私自身でもわかるように `context` の使い方を説明した記事です。

# 準備編: HTTP サーバとハンドラを書いてみよう。

Go を使うと速くて軽い http サーバが簡単に書けるので、ナウでヤングなマイクロサービスを
やりたいときとかに気軽にサーバプログラムを書いたりします。

## 一番簡単な HTTP サーバと、HTTPサーバの動作検証方法

というわけで、 "簡単なサーバ" を書いて実行してみましょう。まずは `main.go` を用意します。

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, World.")
	})
	http.ListenAndServe(":3000", nil)
}
```

で、コンパイルして実行します。

```console
$ go run main.go
```

実行できたらアクセスしてみましょう。

```console
$ curl http://localhost:3000/
Hello, World.
```

ほらね。簡単に http サーバが書けたでしょう？

この記事では、このプログラムをベースとして様々な改造をしていきます。
その際、毎回 `curl` で動作検証をするのは面倒です。
ですので、`go run main.go` で HTTP レスポンス自体を検証できるように、
[httptest](https://golang.org/pkg/net/http/httptest/) を使ってリクエスト・レスポンスの検証をしやすくしておきます。

```go:main.go
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
)

func handleRoot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World.")
}

func main() {
	server := httptest.NewServer(http.HandlerFunc(handleRoot))
	defer server.Close()

	res, _ := http.Get(server.URL)
	body, _ := ioutil.ReadAll(res.Body)
	fmt.Printf("Response: %s\n", body)
}
```

こうしておけば、以下のコマンドですぐに実行できますし...

```
$ go run main.go
Response: Hello, World.
```

手元に Go 言語の開発環境がなくても、Go Playground から [実行可能](https://play.golang.org/p/JIkiuHrBDc3) です。

## 外部 API 呼び出しなどの非同期処理がある場合

さて、Go 言語の特徴の一つとして非同期処理を比較的簡単に書けるというものがあります。
ですので、例えばハンドラ内で外部APIを呼び出したりする場合には、 goroutine を使った非同期かがよく行われます。

具体的なイメージとしては、例えば、下記みたいに ntp 使って時刻を表示するサーバとか

```go:main.go
import "github.com/beevik/ntp"

func handleRoot(w http.ResponseWriter, r *http.Request) {
	time, _ := ntp.Time("ntp.nict.jp")
	fmt.Fprintln(w, time)
}
```

後は、なんか重めな処理を goroutine 使ってバックエンドに流したりするすサーバとかもあるわけです。

```go:main.go
func request(w io.Writer, text string, count int) {
	for i := 0; i < count; i++ {
		time.Sleep(500 * time.Millisecond)
		fmt.Fprintln(w, text)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	go request(w, "foo", 4)
	go request(w, "bar", 4)
	request(w, "baz", 5)
	go request(w, "qux", 4)
}
```

他にも、MySQL などのデータベースの読み書きや、それをラップした DAO, ORM などの処理。
ファイルの読み書きなどディスクIOが発生する何かなどは気軽に goroutine 化して行くことが数多くあるでしょう。

直接 goroutine 化しないとしても、ライブラリ内などでは積極的にされているかもしれません。
このようなとき、上記のような素直すぎるプログラムを書いたとき、真っ先に困るのが *タイムアウト処理の実装* でしょう。

何をどう困るのかを実感するために、サンプルコードとして、ランダムで 0 - 2000 ミリ秒で String を返す `request` メソッドと、それを呼び出すハンドラを用意します。

```go:main.go
// request は 0-2000ミリ秒ランダムで待機した上で、`kind` を返す
func request(kind string) string {
	time.Sleep(time.Duration(rand.Intn(2000)) * time.Millisecond)
	return fmt.Sprintf("%s, ", kind)
}

// handleRoot は　HTTP リクエストのハンドラで、foo, bar, baz, qux をランダムに返す
func handleRoot(w http.ResponseWriter, r *http.Request) {
	c := make(chan string)
	go func() { c <- request("foo") }()
	go func() { c <- request("bar") }()
	go func() { c <- request("baz") }()
	go func() { c <- request("qux") }()

	for i := 0; i < 4; i++ {
		res := <-c
		fmt.Fprint(w, res)
	}
}

func main() {
	server := httptest.NewServer(http.HandlerFunc(handleRoot))
	defer server.Close()

	rand.Seed(time.Now().UnixNano())

  // 一応、所要時間も記録しておく
	start := time.Now()
	res, _ := http.Get(server.URL)
	elapsed := time.Since(start)
	body, _ := ioutil.ReadAll(res.Body)
	fmt.Printf("Response: %s (%s)\n", body, elapsed)
  // main が即終了しないようにしておく
  time.Sleep(2000 * time.Millisecond)
}
```

```console $ go run main.go
Response: bar, baz, foo, qux, (1.860987136s)
```

## タイムアウト処理を実装しようとして、失敗してみる

シンプルにタイムアウトを実装するなら、`c` 以外にもう一つタイムアウト用のチャンネルを用意し、
どちらかが返ってきたら `handleRoot` を打ち切るように実装すれば ok なはずです。
より、処理を簡単にするため、下のコードではさらに `all` チャンネルと 4 つのリクエストを待つ goroutine を用意していきます。

1. タイムアウトして、 "timeout" を返す
2. 4 つの `request` を全て処理しきった結果を返す

のどちらかの挙動となるはずです。

```go:main.go
func handleRoot(w http.ResponseWriter, r *http.Request) {
	c := make(chan string)
	go func() { c <- request("foo") }()
	go func() { c <- request("bar") }()
	go func() { c <- request("baz") }()
	go func() { c <- request("qux") }()

  // 全てのレスポンスを待機するチャンネルを作る
	all := make(chan string)
	go func() {
		var res string
		for i := 0; i < 4; i++ {
			res += <-c
		}
		all <- res
	}()

  // タイムアウトを1500ミリ秒後に設定する
	timeout := time.After(1500 * time.Millisecond)

	select {
	case response := <-all:
		fmt.Fprint(w, response)
	case <-timeout:
		fmt.Fprint(w, "timeout")
	}
	return
}

// request, main は略
```

さて、これでタイムアウトができた。
・・・と、思うでしょう？

例えば、タイムアウト時間を 100 ミリ秒とかに設定すると、期待通りに動かないことがすぐにわかるはずです。

```go
func handleRoot(w http.ResponseWriter, r *http.Request) {
	c := make(chan string)
	go func() { c <- request("foo") }()
	go func() { c <- request("bar") }()
	go func() { c <- request("baz") }()
	go func() { c <- request("qux") }()

	all := make(chan string)
	go func() {
		var res string
		for i := 0; i < 4; i++ {
			res += <-c
			fmt.Printf("all: %s\n", res)
		}
		all <- res
	}()

	timeout := time.After(100 * time.Millisecond)

	select {
	case response := <-all:
		fmt.Fprint(w, response)
	case <-timeout:
		fmt.Fprint(w, "timeout")
	}
	return
}

// request, main は略
```

```
$ go run main.go
Response: timeout (103.853504ms)
all: bar,
all: bar, foo,
all: bar, foo, qux,
```

見ての通り、タイムアウトしたにも関わらず、`all` チャンネルを使う goroutine や、
`request` メソッドを呼び出す goroutine は生きていたままになっていることがわかるかと思います。

この問題は、 *リクエスト全体を通して、処理が完了しているかを示すフラグやチャンネル* があればなんとかなりそうです。

## リクエスト毎の変数的な何か。または context が何を解決するか。

上記に出てきたような *リクエスト全体を通して、処理が完了しているかを示すフラグやチャンネル* 、
リクエスト毎に区切られた認証情報や処理の経過時間みたいな変数、リクエストを中止させる共通のインターフェースなどを用意したのが
[context](https://golang.org/pkg/context/) パッケージです。

* golang でも気軽に `CurrentUserId()` 的メソッドで現在アクセス中のユーザIDが欲しい
* とりあえずエラーを発生させて全ての処理を中止させたい

みたいな要求に気軽に応えられるようになります。

使い方はシンプルで、context を作って、下部のメソッドに渡して行くだけです！　簡単！
（ただし、下部のメソッドは goroutine を作る際に、`ctx.Done()` で処理が終了していないかチェックかけてね！）

```
func handleRoot(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(context.Background(), 2000*time.Millisecond)
	defer cancel()

	c := make(chan string)
	go func() { c <- request("foo") }()
	go func() { c <- request("bar") }()
	go func() { c <- request("baz") }()
	go func() { c <- request("qux") }()

	all := make(chan string)
	go func() {
		var res string
		for i := 0; i < 4; i++ {
			select {
			case r := <-c:
				res += r
				fmt.Printf("all: %s\n", res)
			case <-ctx.Done(): // リクエスト全体が完了しているなら、この goroutine を中止する。
				return
			}
		}
		all <- res
	}()

	select {
	case response := <-all:
		fmt.Fprint(w, response)
	case <-ctx.Done():
		fmt.Fprint(w, "timeout")
	}
	return
}

// request, main は略
```

# Context パッケージはこう使うんだよ

さて、ここまでで context が生まれた背景を説明していきました。

context を使うことで、リクエストを処理する全体で、タイムアウトやキャンセルなどの処理や、リクエスト全体をまたがる変数を取り扱うことができるようになります。

ここからは具体的な使い方を見ていきましょう。

## `Context` 型

[Go Concurrency Patterns: Context - The Go Blog](https://blog.golang.org/context) にも記載がありますが、Context のコアな構造は次の通りです。

```go
// Context はキャンセルフラグやリクエスト毎の変数、リクエストのデッドラインなどを
// API 境界をまたいでアクセスするために使います。各メソッドは複数の goroutine から
// 同時にアクセス可能です。
type Context interface {
  // Context がキャンセルされたりタイムアウトしたりした時に close されるチャンネルを返す
  Done() <-chan struct{}

  // なんでこのコンテキストが中止されたのかを示す error オブジェクト。Done チャンネルが
  // close した後にセットされる
  Err() error

  // Deadline はこのコンテキストがキャンセルされる予定の time.Time を返す
  Deadline() (deadline time.Time, ok bool)

  // このコンテキストに関連づけられた変数
  Value(key interface{}) interface{}
}
```

`Done` 関数はこのリクエスト全体が完了またはキャンセルされた時にシグナルが渡されるチャンネルを返します。
このチャンネルが閉じるか、シグナルが来た場合は、リクエスト全体が終了したため、各 goroutine は直ちに終了する必要があります。
また、 `Err` 関数は、このリクエスト然たがキャンセルまたはエラーで終了した場合、そのエラーを返します。

## 子 goroutine をキャンセルさせる

`Context` にはキャンセルを実行するメソッドは定義されていませんでした。
これは、通常の場合、キャンセルシグナルを受け取る goroutine とキャンセルを実施する goroutine は異なるためです。

例えば、ある goroutine A があり、 A が新しく goroutine B を呼び出す場合で考えますと

* A は B をキャンセルできます
* B は A をキャンセルできません
* A は A 自身をキャンセルできません。(return で抜けることはできるでしょう)
* B は B 自身をキャンセルできません。(return で抜けることはできるでしょう)

と整理できます。
この場合、A は B にキャンセル可能なコンテキストを渡す必要があり、 [context.WithCancel](https://tip.golang.org/pkg/context/#WithCancel) で作成可能です。

例を見せましょう。

まず、コンテキストを受け取り、キャンセル可能な無限ループを作ります。

```go
// infLoop は無限ループを行います。渡された context が終了した際にはこの関数を抜けます。
func infLoop(ctx context.Context) {
	fmt.Println("start infLoop")
	for {
		select {
		case <-ctx.Done():
			fmt.Println("exit infLoop")
			return
		}
	}
}
```

main では [context.Background](https://tip.golang.org/pkg/context/#Background) で新しいコンテキストを作った上で、
この親コンテキストをもとにキャンセル可能な子コンテキストを作り、 `infLoop` に渡します。

```
func main() {
	rand.Seed(time.Now().UnixNano())

	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)

	go infLoop(ctx)
```

後は、好きなタイミングで `cancel()` を呼び出せば、 `infLoop` は終了します。

```
	go infLoop(ctx)

  time.Sllep(1000 * time.Millisecond)
  cancel()
}
```

実行可能なプログラムの全体像は以下の通りです。

```
package main

import (
	"context"
	"fmt"
	"math/rand"
	"time"
)

// infLoop は無限ループを行います。渡された context が終了した際にはこの関数を抜けます。
func infLoop(ctx context.Context) {
	fmt.Println("start infLoop")
	for {
		select {
		case <-ctx.Done():
			fmt.Println("exit infLoop")
			return
		}
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())

	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)

	go infLoop(ctx)

  time.Sleep(1000 * time.Millisecond)
  fmt.Println("do cancel")
  cancel()

  // main が終了しないように sleep を挟んでおく
	time.Sleep(1000 * time.Millisecond)
}
```

実行結果は以下のようになります。

```console
$ go run main.go
start infLoop
do cancel
exit infLoop
```

## 子 goroutine をタイムアウトさせる

ほぼ、上記のキャンセルと同様ではありますが、タイムアウト処理には [context.WithDeadline](https://tip.golang.org/pkg/context/#WithDeadline) と
[context.WithTimeout](https://tip.golang.org/pkg/context/#WithTimeout) の二つが使えます。

WithDeadline は指定時刻に、WithTimeout は指定時間経過後にそれぞれキャンセルされます。

## cancel() の呼び出しはどこに書くか？

ここまでのコード例では、 `time.Sleep` を多用したため、 `cancel()` を手動で呼び出していました。
しかし、大抵の場合、 `foo` 関数で子 goroutine を作りっぱなしにすることはなく、 `foo` が終了するタイミングで子 goroutine も後始末することが多いでしょう。
ですので、 `defer` を使って下記のように書くことが多いと思います。

```go
func foo(ctx context.Context) {
  ctx, cancel := context.WithCancel(ctx)
  defer cancel()

  go func(ctx) {
    // ...
  }(ctx)
}
```

## コンテキストで値を渡す

[context.WithValue](https://tip.golang.org/pkg/context/#example_WithValue) を使い、値を渡します。
重要なのは、ここで渡す値は、例えばリクエストの処理の間、ずっと受け渡したい値であり、gorouitne や関数のオプションに渡すべきではないということです。
（この関数を使うと便利に値が渡せてしまいますので、濫用に注意しましょう）

`context.WithValue` では、`key` と `val` のそれぞれに `interface` が使えます。

## コンテキストの木構造

`Context` は親子関係を持っています。 `WithCancel` や `WithTimeout`, `WithValue` などを呼び出すことで、どんどん子 `Context` ができていきます。
親の `Context` がキャンセルされた場合、子供や子孫のコンテキストに `Done` が送信されます。

では、最上位の根 `Context` はどうやって作れば良いのでしょうか？？

[context.Background](https://tip.golang.org/pkg/context/#Background) がそれになります。

このコンテキストはキャンセルもできませんし、タイムアウト設定などもされていません。

# まとめと Context を使う際のルールについて

`context` パッケージを使うと、リクエストの処理中の値を取り扱いや、リクエスト自体がキャンセルされた際の、子 goroutine の適切なキャンセルなどをとてもスッキリと記述できます。
・・・が、それにはいくつかルールが必要です。

[Go Concurrency Patterns: Context - The Go Blog](https://blog.golang.org/context) の最後に、Google 社内でのルールについて記されています。
まず、 `context` を用いる全ての関数で、最初の引数として `context` を受け取れるようにしています。
この時、 *必ず第１引数* にしています（社内規約です）。
また、 `context` を用いた関数が goroutine を呼び出すなら、適切なキャンセル処理をする必要があります。
このルールに従うことで、謎の goroutin がサーバ上で残るなど変な不具合がぐっと減らせるはずでしょう。

サンプルコードは https://github.com/ayasuda/sandbox/tree/master/go_context においてあります。

# 参照

* [context - The Go Programming Language](https://tip.golang.org/pkg/context/)
* [Go Concurrency Patterns: Context - The Go Blog](https://blog.golang.org/context)
* [Go1.7のcontextパッケージ | SOTA](https://deeeet.com/writing/2016/07/22/context/)
* [golangでcontextパッケージを使う - write ahead log](https://twinbird-htn.hatenablog.com/entry/2017/04/07/214420)
* [Go Concurrency Patterns: Pipelines and cancellation - The Go Blog](https://blog.golang.org/pipelines)
* [Go の Context を学ぶ - Qiita](https://qiita.com/TsuyoshiUshio@github/items/34b63b663ffd56125c07)
* [golang contextの使い方とか概念(contextとは)的な話 - Qiita](https://qiita.com/marnie_ms4/items/985d67c4c1b29e11fffc)
