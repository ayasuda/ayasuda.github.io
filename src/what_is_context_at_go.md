
Golang を使って何を書くかといえば、なんだかんだでサーバプログラムを書くことが多いかと思います。
大抵の場合、ハンドラは goroutine で動かすことになります。また、ハンドラの中で goroutine 動かすケースも多々あります。
さて、例えばハンドラ内で外部 API を呼び出したり、マイクロサービスな関連サーバへリクエストをかけたりする際に、
それぞれのリクエストで AccessToken やタイムアウトの規定時間など、共通の値を用いるケースは多々あるかと思います。
また、 goroutine で平行で動かしているリクエストがある時、１つが失敗したら残りのリクエストも全部失敗させたいときなどもあり得るでしょう。

`context` パッケージはそのような、リクエスト毎のデータを取り扱うために作られました。

この文書は

* [Go Concurrency Patterns: Context - The Go Blog](https://blog.golang.org/context)
* [Go1.7のcontextパッケージ | SOTA](https://deeeet.com/writing/2016/07/22/context/)

あたりの内容を、よりバカバカしく、２ヶ月後の私自身でもわかるように開設した記事です。

# なぜ context パッケージが嬉しいのか - 簡単に実装しすぎた API サーバのつらみ

Go を使うと速くて軽い http サーバが簡単に書けるので、ナウでヤングなマイクロサービスを
やりたいときとかに気軽にサーバプログラムを書いたりします。

## ね？　簡単でしょ？　go で作る http サーバ

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

この文書では説明のためにこのプログラムを改造していきます。改造内容を確認しやすいように、
`go run main.go` したら `http://localhost:3000/` へのアクセス内容をすぐにみられるように
`httptest` パッケージを使ってリクエスト/レスポンスを見られるようにしておきましょう。

```go:main.go
package main

import (
	"fmt"
	"github.com/beevik/ntp"
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

Go Playground から [実行可能](https://play.golang.org/p/JIkiuHrBDc3) です。

## 最近は外部 API 呼び出しとか、非同期処理とか多いらしいよ？

さて、世の中には外部APIを呼び出すサーバなんていっぱいあるわけですよ。
例えば、下記みたいに ntp 使って時刻を表示するサーバとか

```go
import "github.com/beevik/ntp"

func handleRoot(w http.ResponseWriter, r *http.Request) {
	time, _ := ntp.Time("ntp.nict.jp")
	fmt.Fprintln(w, time)
}
```

後は、なんか重めな処理を goroutine 使ってバックエンドに流したりするすサーバとかもあるわけです。

```go
func say(w io.Writer, text string, count int) {
	for i := 0; i < count; i++ {
		time.Sleep(500 * time.Millisecond)
		fmt.Fprintln(w, text)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	go say(w, "foo", 4)
	go say(w, "bar", 4)
	say(w, "baz", 5)
	go say(w, "qux", 4)
}
```

他にも、MySQL などのデータベースの読み書きや、それをラップした DAO, ORM などの処理。
ファイルの読み書きなどディスクIOが発生する何かなどは気軽に goroutine 化して行くことが数多くあるでしょう。

直接 goroutine 化しないとしても、ライブラリ内などでは積極的にされているかもしれません。

素直にプログラムを書いたとき、真っ先に困るのが *タイムアウト処理の実装* です。

まずはサンプルコードとして、ランダムで 0 - 2000 ミリ秒で String を返す `request` メソッドと、それを呼び出すハンドラを用意しましょう。

```go
func request(kind string) string {
	time.Sleep(time.Duration(rand.Intn(2000)) * time.Millisecond)
	return fmt.Sprintf("%s, ", kind)
}

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
	start := time.Now()
	res, _ := http.Get(server.URL)
	elapsed := time.Since(start)
	body, _ := ioutil.ReadAll(res.Body)
	fmt.Printf("Response: %s (%s)\n", body, elapsed)
}
```

```
$ go run main.go
Response: bar, baz, foo, qux, (1.860987136s)
```

さて、このコードにタイムアウトをシンプルに仕込むなら、 `c` 以外にもう一つタイムアウト用のチャンネルを用意し、
どちらかが返ってきたら `handleRoot` を打ち切るように実装すればお ok なはずです。
より、処理を簡単にするため、下のコードではさらに `all` チャンネルと 4 つのリクエストを待つ goroutine を用意しています。

これにより

1. タイムアウトして、 "timeout" を返す
2. 4 つの `request` を全て処理しきった結果を返す

のどちらかの挙動となります。

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
		}
		all <- res
	}()

	timeout := time.After(1500 * time.Millisecond)

	select {
	case response := <-all:
		fmt.Fprint(w, response)
	case <-timeout:
		fmt.Fprint(w, "timeout")
	}
	return
}
```

さて、これでタイムアウトができた。・・・と、思うでしょう？

ちょっとコードをこんな風に改修し、タイムアウトを思いっきり短く、例えば 100ms とかにしてみて実装してみましょう。

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
```

```
$ go run main.go5
Response: timeout (103.853504ms)
all: bar,
all: bar, foo,
all: bar, foo, qux,
```

見ての通り、タイムアウトしたにも関わらず、`all` チャンネルを使う goroutine や、
`request` メソッドを呼び出す goroutine は生きていたままになっていることがわかるかと思います。

この問題は、 *リクエスト全体を通して、処理が完了しているかを示すフラグやチャンネル* があればなんとかなりそうです。

## リクエスト毎の変数的な何か

上記に出てきたようか *リクエスト全体を通して、処理が完了しているかを示すフラグやチャンネル* 、
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
			case <-c:
				res += <-c
				fmt.Printf("all: %s\n", res)
			case <-ctx.Done():
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
```

# Context パッケージはこう使うんだよ

さて、ここまでで context が生まれた背景、具体的にはリクエストハンドラみたいなメソッド内で
キャンセルフラグやリクエスト毎の変数を goroutien や API 境界をまたいで統一的なIFで操作したいから生まれたという説明をしてきました。

ここからは具体的な使い方を見ていきましょう。

## 基本的な構造と新しいコンテキストの作り方

[公式ドキュメント(ブログ)](https://blog.golang.org/context) にも記載がありますが、Context のコアな構造は次の通りです。

```
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

また context パッケージには、 親となる Context から子 Context を作る各種関数が用意されています。
そう、言っていませんでしたが Context は木構造を取るのです。（そしてキャンセル処理はいい感じに伝播するので安心）

[context.Background](https://golang.org/pkg/context/#Background) は `nil` ではない、空のコンテキストを作ります。
このメソッドは一般的に main 関数や初期化関数などで呼ばれ、リクエスト毎のトップレベルコンテキストとします。

[context.WithCancel](https://golang.org/pkg/context/#WithCancel), [context.WithDeadline](https://golang.org/pkg/context/#WithDeadline),
[context.WithTimeout](https://golang.org/pkg/context/#WithTimeout), [context.WithValue](https://golang.org/pkg/context/#WithValue) は
それぞれ、既存のコンテキストを親にして新しくコンテキストを作るメソッドです。

そんなわけで、キャンセル可能なコンテキストはこんな風に作ります。

```
ctx, cancel := context.WithTimeout(context.Background(), 2000*time.Millisecond)
defer cancel()
```

context.WithCancel はキャンセル用の関数を２番目の戻り値として返すので、 `defer` で呼び出してやるととても良いでしょう。

## コンテキストを使う関数と、キャンセル処理

さて、 Context を使う関数は以下のルールに従う必要があります。

1. 下に示すサンプルコード見たいなインターフェースにします。具体的には第１引数に context を取るようにしましょう。なお、一般的に引き数名は `ctx` にします。
2. もらってきた context を構造体の中に格納したりしてはいけません。
3. nil を下位に渡してはいけません。許されててもやめたほうが良いでしょう。信頼できないのでコンテキストを渡したくないときは `context.TODO` を渡しましょう。
4. Context の Value にはリクエスト毎で共通のデータを入れましょう。下位の関数向けのパラメタは Context の Value ではなく、ちゃんとパラメタとして渡しましょう。
5. Context を受け取った上で、 goroutine を呼び出すなら、キャンセル処理を書きましょう。

```
func DoSomething(ctx contet.Context, arg Arg) error {
  // なんかの処理


}
```


// 使い方

// パッケージ毎のあれ

// CurrentUser を実装してみるなら
