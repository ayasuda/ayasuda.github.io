---
title: 'Go 言語でのシグナル処理'
date: '2021-10-12'
description: ''
keywords:
  - Signal
  - Go
---

Go 1.17.1 にて検証済みです

シグナル処理とは何か？　については [シグナル処理ことはじめ](/what_is_signal) にてまとめました。
ここでは、 Go 言語でシグナル処理をどのようにやるのかについてまとめていきます。

まずはサンプルコードをベースに基本的な機能を紹介します。
次に、使用しているパッケージの詳細な説明をしていこうと思います。

# サンプルコード

無限ループしながら１秒に１ずつカウントを標準出力に書き、
`Ctrl + C` を受け取ったら "bye" と書いて終了するプログラムをもとに解説していきます。
サンプルコードは [github](https://github.com/ayasuda/sandbox/blob/master/go/signal/basic/main.go) にアップロード済みです。

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	// 1 秒に 1 回起動する ticker を作成する
	// 具体的には Ticker.C という chan Time なチャンネルに指定間隔で変数が投げられるようになります
	ticker := time.NewTicker(1 * time.Second)

	// 終了処理用に bool 型のチャンネルを用意する
	done := make(chan bool, 1)

	// シグナル受信用のチャンネルを用意する
	sigs := make(chan os.Signal, 1)

	// プログラムがシグナルを受信した際に、チャンネルに通知するように設定する
	// 具体的には `os.Interrupt` (SIGINT のこと) をプログラムが受信したら
	// sigs 変数のチャンネルに通知するように設定しています
	signal.Notify(sigs, os.Interrupt)

	cnt := 0

	// 以下の関数を、goroutine として非同期に実行開始する
	go func() {
		for {
			// ticker.C チャンネルに何か来るまで for ループを止める
			// ticker のところでも解説しましたが、1 秒に1回、Time 型の変数が投げられます
			<-ticker.C
			cnt += 1
			fmt.Println(cnt)
		}
	}()

	// 以下の関数を、goroutine として非同期に実行開始する
	go func() {
		// sigs チャンネルに何かが来るまで goroutine を止める
		<-sigs

		// 標準出力に "bye" と表示する
		fmt.Println("bye")

		// 後始末として ticker を止める
		ticker.Stop()

		// done チャンネルに true を投げる
		done <- true
	}()

	// done チャンネルに何かが来るまでプログラムを止める
	<-done
}
```

以下のコマンドでこのコードは実行可能です。

```
$ go run main.go
```

コードを実行すると、１秒毎に数字をカウントアップし続けます。
終了したい場合は `Ctrl + C` を入力します。

## Signal 型

公式ドキュメントは https://pkg.go.dev/os@go1.17.1#Signal にあります。

```go
type Signal interface {
	String() string
	Signal() // 他の Stringer な interface と区別するためのダミー用定義なので使わない
}
```

`os` パッケージの `Signal` 型は OS からのシグナルを表します。
実際の実装は OS 毎に異なり、特に Unix 系の OS は `syscall` パッケージの `Singal` に定数が定義されています。

`os` パッケージに直接定義されているシグナルは以下の２つです。

```go
var (
	Interrupt Signal = syscall.SIGINT
	Kill Signal      = syscall.SIGKILL
)
```

この２つのシグナルはすべての OS で使用可能です。

## syscall パッケージの定数

公式ドキュメントは https://pkg.go.dev/syscall#SIGABRT にあります。

各種シグナル用の定数が用意されており、上記で示した `Signal` として利用可能です。
ただし、このパッケージを直接使うよりも、より抽象化した `os` や `time`, `net` パッケージなどを使うようにしたほうが良いです。

このパッケージ自体は、現在ロックダウン中で、各種 OS に特化したシステム依存の定数などは
`golang.org/x/sys` パケージを利用するようにしてください。

こうなった背景は以下を参照すると良いでしょう

* https://golang.org/s/go1.4-syscall
* [Go Binary Hacks - syscallとgolang.org/x/sys/ #golang - Qiita](https://qiita.com/sonatard/items/f03883ac061cf9fe4718)

## Notify 関数

公式ドキュメントは https://pkg.go.dev/os/signal@go1.17.1#Notify にあります

プログラムがシグナルを受け取った際に指定したチャンネルに送るように設定する関数です。
チャンネルを必要十分なスペースがある必要があります。size が 1 であれば十分です。

第２引数のチャンネルを指定しなかった場合は、すべてのシグナルがチャンネルに流れるようになります。

```go
sigs := make(chan os.Signal, 1)
signal.Notify(sigs) // すべてのシグナルが sigs に流れるようになる
```

この関数は複数回呼び出し可能でその度に送信先のチャンネルが切り替わります。

以下がサンプルコードです。
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/multi_notify/main.go) にアップロード済み)

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
)

func main() {
	done := make(chan bool, 1)
	s1 := make(chan os.Signal, 1)
	s2 := make(chan os.Signal, 1)

	go func() {
		<-s1
		fmt.Println("got s1")
		done <- true
	}()
	go func() {
		<-s2
		fmt.Println("got s2")
		done <- true
	}()

	signal.Notify(s1, os.Interrupt)

	<-done

	signal.Notify(s2, os.Interrupt)

	<-done
}
```

このプログラムは２回 SIGINT シグナルを受け取って終了するように作られており、
１回目は `s1` に、２回目は `s2` にシグナルが送られます。

# os.Signal パッケージ

Go 言語でのシグナル制御については、組み込みパッケージの [os/signal](https://pkg.go.dev/os/signal) ドキュメントが一番詳しく纏まっています。

デフォルトでは各種非同期シグナルはランタイムパニックに変換されます。
具体的には以下のとおりです。

* SIGHUP, SIGINT, SIGTERM はプログラムの実行を終了します
* SIGQUIT, SIGILL, SIGTRAP, SIGABRT, SIGSTKFLT, SIGEMT, SIGSYS はスタックをダンプしつつプログラムを終了します
* SIGTSTP, SIGTTIN, SIGTTOU はシステムに定義されているデフォルトの振る舞いをします
* SIGPROF は Go ランタイムに直接実装されている runtime.CPUPRofile によって処理されます
* それ以外のシグナルは無視されます

さて、 os/signal パッケージを使うことで、これらの挙動を変更することが可能です。
具体的には先に説明した `Notify` 関数を使うことで指定したチャンネルにシグナルを渡すように設定することができます。

また、Notify で設定した各種チャンネルの登録は、 os/signal パッケージの他の関数を使うことで適宜動作を変更可能です。

以下、 各種関数についてサンプルコードとともに動きを見ていきましょう

## Ignore

`Ignore` を使うことで、プログラムの実行中に特定のシグナルを無視させられます。
以下は、 SIGINT を開始後10秒間無視させるプログラム
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/ignore/main.go))
です。

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	// 復帰できるように 10 秒タイマーを作っておきます。
	t := time.NewTimer(10 * time.Second)
	sigs := make(chan os.Signal, 1)

	fmt.Println("ignore Ctrl + C")

	// Ignonre を呼び出し、 Ctrl + C を無視させます
	signal.Ignore(os.Interrupt)

	go func() {
		// 10 秒経過後、Ctrl + C を受け取れるようにします
		<-t.C
		t.Stop()

		fmt.Println("start to accept Ctrl + c")
		signal.Notify(sigs, os.Interrupt)
	}()

	<-sigs
	fmt.Println("bye")
}

```

実行すると、10秒間は何も操作できません

```
$ go run main.go
ignore Ctrl + C
```

10 秒経つと `Ctrl + C` が入力可能になり、入力すると、 "bye" と表示してプログラムが終了します

```
start to accept Ctrl + c
^Cbye
```

## Ignored

特定のシグナルが `Ignore` で無視されるように設定されているかを確認する関数です。
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/ignored/main.go))

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	tm := time.NewTimer(10 * time.Second)
	ti := time.NewTicker(1 * time.Second)
	sigs := make(chan os.Signal, 1)

	fmt.Println("ignore Ctrl + C")
	signal.Ignore(os.Interrupt)

	go func() {
		for {
			<-ti.C
			if signal.Ignored(os.Interrupt) {
				fmt.Println("ignoring Ctrl + C")
			} else {
				fmt.Println("wait Ctrl + C")
			}
		}
	}()

	go func() {
		<-tm.C
		tm.Stop()

		fmt.Println("start to accept Ctrl + c")
		signal.Notify(sigs, os.Interrupt)
	}()

	<-sigs
	ti.Stop()
	fmt.Println("bye")
}

```

実行すると、1秒ごとに Ctrl + C が受付可能か表示されます
10 秒経つと `Ctrl + C` が入力可能になり、入力すると、 "bye" と表示してプログラムが終了します

```
$ go run main.go
ignore Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
ignoring Ctrl + C
start to accept Ctrl + c
wait Ctrl + C
wait Ctrl + C
wait Ctrl + C
^Cbye
```

## NotifyContext

公式ドキュメントは https://pkg.go.dev/os/signal@go1.17.1#NotifyContext にあります

Context そのものの説明については [Context についての記事](/what_is_context_at_go) を読んでもらうとして、
Go 言語の世界では外部プロセスの起動や API 呼び出しなど、並行に行いたい処理を実施する際には `Context` を
呼び出し元から呼び出し先に渡してやるのが一つのお約束となっていました。
そのようにすることで、タイムアウトや呼び出し元からのキャンセル処理などが書きやすくなっていました。

さて、呼び出し元からのキャンセルとしてあり得るのが、そもそものプログラムが *シグナル受信によって終了* するケースです。

Go 1.15 まではこれらの処理を手作業で書いていましたが、 Go 1.16 からは `NotifyContext` が追加され、処理をきれいに書けるようになりました。


`NotifyContext` では親となる Context と受け取るシグナルを引数とし、子となる Context と 停止用関数が返されます。

この子となる `Context` の `Done()` チャンネルが閉じられるのは以下の３通りです

1. `NotifyContext` で指定したシグナルを受信した時
2. `NotifyContext` が返す `stop` 関数が直接呼び出された時
3. `NotifyContext` に渡す親コンテストの `Done` チャンネルが閉じられる時

サンプルで説明しましょう

以下のサンプルは、４つの方法で終了するプログラムです
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/notify_context/main.go))

1. 開始から 10 秒経つと、自動的に終了します
2. `Ctrl + C` を入力すると、 `ctx` の `Done()` チャンネルが閉じられ、終了します
3. `exit` と入力すると、 `stop()` が呼び出されることにより `ctx` の `Done()` チャンネルが閉じられ終了します
4. `cancel` と入力すると `parent` コンテキストがキャンセルされ (`cancel()` が呼び出され) ることにより `ctx` の `Done()` チャンネルが閉じられ終了します

```go
package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	parent, cancel := context.WithCancel(context.Background())

	ctx, stop := signal.NotifyContext(parent, os.Interrupt)
	defer stop()

	go func(ctx context.Context) {
		// 親から context 受け取ってるけど特にすることないので無視
		// 本当は 親 context が終了した時の処理書いたほうがいいです

		for {
			var in string
			fmt.Scanln(&in)
			fmt.Println(in)
			switch in {
			case "cancel":
				fmt.Println("canceled")
				cancel()
			case "exit":
				fmt.Println("exited")
				stop()
			default:
				fmt.Println(in)
			}
		}
	}(ctx)

	select {
	case <-time.After(10 * time.Second):
		fmt.Println("time out")
	case <-ctx.Done():
		stop()
		fmt.Println("interuppted")
	}
}
```

## Reset

公式ドキュメントは https://pkg.go.dev/os/signal@go1.17.1#Reset にあります

`Notify` で設定したシグナル受信設定を解除する関数です。
第１引数を省略すると、プログラム中で設定した全てのシグナル受信が解除されます。

解除されたシグナルが送られてきた場合には、上記の方に記した「デフォルトの挙動」通りの動作となります。

下に示した例
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/reset/main.go))
は、本ページ上部に記載した基本例を修正し、 `Ctrl + C` を受け取らないようにしたものです。

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	ticker := time.NewTicker(1 * time.Second)

	done := make(chan bool, 1)
	sigs := make(chan os.Signal, 1)

	// プログラムが Ctrl + C を受信した際に、チャンネルに通知するように設定する
	signal.Notify(sigs, os.Interrupt)

	cnt := 0

	go func() {
		for {
			<-ticker.C
			cnt += 1
			fmt.Println(cnt)
		}
	}()

	// Ctrl + C をこのプログラムで処理しないようにする　
	signal.Reset(os.Interrupt)

	go func() {
		// sigs チャンネルが Ctrl + C を受信することがないので、以下のステップには到達しなくなります
		<-sigs
		fmt.Println("bye")
		ticker.Stop()
		done <- true
	}()

	<-done
}
```

このプログラムを実行することで、 `Ctrl + C` が入力された時に "bye" ではなく、go ランタイムデフォルトの表示がされるようになります。

```
$ go run main.go
^Csignal: interrupt
```

## Stop

公式ドキュメントは https://pkg.go.dev/os/signal@go1.17.1#Stop にあります

`Reset` に似ていますが、こちら
([github](https://github.com/ayasuda/sandbox/blob/master/go/signal/stop/main.go))
はチャンネルを指定して受信を停止する関数です。

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"time"
)

func main() {
	ticker := time.NewTicker(1 * time.Second)

	done := make(chan bool, 1)
	sigs := make(chan os.Signal, 1)

	signal.Notify(sigs, os.Interrupt)

	cnt := 0

	go func() {
		for {
			<-ticker.C
			cnt += 1
			fmt.Println(cnt)
		}
	}()

	// sigs チャンネルでシグナルを受信するのを停止する
	signal.Stop(sigs)

	go func() {
		// sigs チャンネルが Ctrl + C を受信することがないので、以下のステップには到達しなくなります
		<-sigs
		fmt.Println("bye")
		ticker.Stop()
		done <- true
	}()

	<-done
}
```

このプログラムを実行することで、 `Reset` と同じように `Ctrl + C` が入力された時に "bye" ではなく、go ランタイムデフォルトの表示がされるようになります。

```
$ go run main.go
^Csignal: interrupt
```
