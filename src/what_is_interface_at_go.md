---
title: 'Blog template'
date: '2100-12-31'
description: ''
keywords:
  - Java
  - Maven
---

Go 言語の interface とは何か

基礎から学ぶ interface
====

interface の基本的な使い方を実際のコード例を見ながら見ていきましょう。
なお、この章で述べている内容は [A Tour of Go](https://go-tour-jp.appspot.com/list) の
[Interfaces](https://go-tour-jp.appspot.com/methods/9) から
[Type switches](https://go-tour-jp.appspot.com/methods/16)
までの焼き直しです。

言語仕様から見る interface
----

公式ドキュメントは [こちら](https://golang.org/ref/spec#Interface_types) です。

ドキュメントに記してある通り、 `interface` とは、メソッドの宣言の集まりです。
`interface` 型の変数は、宣言されたメソッドを全て実装した任意の型の値を持つことができます。

動かしながら学ぶ interface
----

さて、言語仕様にも記した通り `interface` はメソッドの宣言で定義できます。

例として、 `Gunmer` という interface を定義してみましょう。
`Gunmer` には、 `Gunma() string` というメソッドが宣言されていることとします。


```go
type Gunmer interface {
  Gunma() string
}
```

これにより、`Gummer` 型の変数を使えるようになりました。

```go
func main() {
  var g Gunmer
}
```

この変数 `g` には、`Gunma() string` が定義された値のみが代入可能となります。
ですので、例えば `S1` という構造体と、その構造体をレシーバーとする `Gunma() string` を定義することで、 `g` に代入ができます。

```go:gunma.go
import "fmt"

type Gunmer interface {
  Gunma() string
}

func main() {
  var g Gunmer

  g = S1{}

  fmt.Println(g.Gunma())
}

type S1 struct{}

func (s S1) Gunma() string {
  return "Gunma"
}
```

このコードを、例えば `gunma.go` という名前で保存し、実行すると、 `func (s S1) Gumna() string` が呼び出されることがわかります。

```console
$ cd path/to/gunma
$ go run gunma.go
Gunma
```

[playground](https://play.golang.org/p/kFEWkTMQB9f)

`g` には `Gunma() string` が実装された値ならなんでも代入できますので、例えば `string` に `Gunma() string` を実装すれば、
`g` に `string` が代入可能になります。

ただし、レシーバーを伴うメソッドの宣言は同一パッケージ内でしか宣言できません。
つまり `func (s string) Gunma() string` は `string` が宣言されているパッケージでしか行えません。

ですので、新しく `MyString` を宣言し、`MyString` に `Gunma()` を定義してやります。

```go:gunma.go
import "fmt"

type Gunmer interface {
  Gunma() string
}

func main() {
  var g Gunmer

  g = S1{}

  fmt.Println(g.Gunma())

  g = MyString("g")

  fmt.Println(g.Gunma())
}

type S1 struct{}

func (s S1) Gunma() string {
  return "Gunma"
}

type MyString string

func (s MyString) Gunma() string {
  return string(s + " is Gunma")
}
```

このコードを、例えば `gunma.go` という名前で保存し、実行すると、 `func (s S1) Gumna() string`,
`func (s MyString) Gunnma() string` が呼び出されることがわかります。

```console
$ cd path/to/gunma
$ go run gunma.go
Gunma
g is Gunma
```

[playground](https://play.golang.org/p/VxDYAd-x9DP)

ここまでの例で `g` に、`Gunmna() string` を実装していない値を入れようとするとどうなるでしょう？

答えは単純で、エラーになります。

```go
// これはできません。なぜなら string には Gunma() が実装されていないためです
g = "pure string"
```

interface の値と nil について
----

具体的に `g` の中には何が入っているかを見て見ましょう。

`fmt.Printf` を使えば中身をがわかりやすく見られます。
`%v` を使えば、デフォルトフォーマットでの変数の値が表示されます。
`%T` を使えば、Go 言語で型を書いた時の書き方が見られます。

```go:printf.go
import (
  "fmt"
  "time"
  )

func main() {
  s := "this is sample"
  fmt.Printf("(value: %v, type: %T)\n", s, s)

  i := 43
  fmt.Printf("(value: %v, type: %T)\n", i, i)

  t := time.Now()
  fmt.Printf("(value: %v, type: %T)\n", t, t)
}
```

上のコードを実行すると、例えば次のようになります。

```console
$ go run printf.go
(value: this is sample, type: string)
(value: 43, type: int)
(value: 2019-08-27 20:08:15.577102 +0900 JST m=+0.000255514, type: time.Time)
```

これを使って、 `var g Gunmer` の中身を見て見ると、次のようになります。

```go:gunma.go
import "fmt"

type Gunmer interface {
  Gunma() string
}

func main() {
  var g Gunmer

  g = S1{}

  fmt.Printf("(value: %v, type: %T)\n", t, t)

  g = MyString("g")

  fmt.Printf("(value: %v, type: %T)\n", t, t)
}

type S1 struct{}

func (s S1) Gunma() string {
  return "Gunma"
}

type MyString string

func (s MyString) Gunma() string {
  return string(s + " is Gunma")
}
```

```console
$ go run gunma.go
(value: {}, type: main.S1)
(value: g, type: main.MyString)
```

ご覧のように、`var g Gunmmer` は、値としてはそれぞれの具体的な値が、
`type` としては、それぞれの具体的な型が保持されています。

ところで、構造体のポインタを受ける変数は `nil` が取れました。
interface の値である `g` も `nil` にすることができるでしょうか？

もちろん、 `g` は値として `nil` が取れます。

次のコードで実験して見ましょう。

先程までのコードと違い、`S1` 自身は `Gunmer()` を持たず、 `*S1` に `Gunmer()` が定義されています。

```go
package main

import "fmt"

type Gunmer interface {
	Gunma() string
}

func main() {
	var g Gunmer

	fmt.Printf("(value: %v, type: %T)\n", g, g)

	var s1 *S1

	g = s1

	fmt.Printf("(value: %v, type: %T)\n", g, g)

	g = &S1{}

	fmt.Printf("(value: %v, type: %T)\n", g, g)
}

type S1 struct{}

func (s *S1) Gunma() string {
	return "Gunma"
}
```

このコードを実行すると、それぞれ次のようになります。

```
$ go run gunma.go
(value: <nil>, type: <nil>)
(value: <nil>, type: *main.S1)
(value: &{}, type: *main.S1)
```

このように、参照している型が `nil` な Gummer 型の `g` や、
具体的な値が `nil` な `g` は存在しえます。

ただし、具体的な値が `nil` だけど参照している型も `nil` な `g` は作成できません。

なお、具体的な値が `nil` な `g` は `g.Gunma()` の呼び出しが可能です。
ですので、 `func (s *S1) Gunma()` を実装する際には、 `s` が `nil` でも大丈夫なように実装する必要があります。
　
```go
package main

import "fmt"

type Gunmer interface {
	Gunma() string
}

func main() {
	var g Gunmer
	var s1 *S1
	g = s1

	fmt.Println(g.Gunma())
}

type S1 struct{}

func (s *S1) Gunma() string {
	if s == nil {
		return "<nil> is Gunma"
	}
	return "s is Gunma"
}
```

```console
$ go run gunma.go
<nil> is Gnuma
```

interface 型と interface 値の再理解
----

ここまでの話をもう少しゆっくりとまとめましょう。
大事なのは次の 3 点です。。

1. `itnerface` は型の一つです
2. `interface` の中には、実装すべきメソッドの宣言を記すことができます
3. `interface` 型の変数は、実装すべきメソッドが全て実装された任意のかたの値を持つことができます。

まず、`interface` は型の一つです。ですので `type` キーワードで新しく宣言が可能です。

`type MyInterface interface {}`

`interface` 型の中にはメソッドの宣言を記すことができます。

```go
interface {
  Foo() bool
  Bar() string
  Baz(qux int)
}
```

プログラム中で `interface` 型の変数を宣言できます。

```go
var foo interface {
  String() string
}
```

interface 型の変数は、メソッドが全て実装された任意の型の値を持つことができます。

例えば、上の `foo` には、`time.Time` が代入可能です。
これは、 `time.Time` が `func (t time.Time) String() string` を実装しているためです。

```go

package main

import (
	"fmt"
	"time"
)

func main() {
	var foo interface {
		String() string
	}

	foo = time.Now()

	fmt.Println(foo)
}
```

空の interface
----

go 言語には任意の型を扱う方法が１つだけあり、それは、この「空のinterface」を用いた方法です。

空の interface とは、実装すべきメソッドが空の interface のことです。

```go
var foo inteface{}
```

上で述べたとおり、 inteface 型の値には、実装すべきメソッドが全て実装された任意の型の値を代入することができます。
「空のinterface」では、実装すべきメソッドがありません。
つまり、任意の型の値が保存できます。

```go
var foo interface{}

foo = "bar"

foo = 18

foo = 21.8
```

型アサーション構文
----

interface には、保存されている値が特定の型かチェックする「型アサーション構文」が用意されています。

公式ドキュメントは[こちら](https://golang.org/ref/spec#Type_assertions)です。

上にも記した通り、 interface 型の変数は値と、参照している具体的な型の２つが保存されています。

go 言語では次の構文で、 interface 型の変数と、具体的な型とのチェックが行えます。

```go
x.(T)
```

この構文では、`x` が `nil` ではなく、かつ、 `x` が `T` 型かどうかがチェックされます。

何も考えずに使った場合、型アサーションに成功するとその値が、失敗すると panic を引き起こしてプログラムが終了します。


```go
var i interface{} = "string value"

s := i.(string) // これは動く。 s には "string value" がはいる
f := i.(float64) // ここになった瞬間 panic になって死ぬ
```

テスト用の変数を受け取ることで、型アサーションに成功したかどうかを受け取ることができます。
この場合、型アサーションに失敗すると最初の返り値はゼロ値になります。

```go
var i interface{} = "string value"

f, ok := i.(float64) // f が 0 に、ok には false がはいる
```

もちろん、型アサーションは任意の interface に使えます。

```go
package main

import "fmt"

type Gunmer interface {
	Gunma() string
}

func main() {
	var g Gunmer

	g = S1{}

	var v Gunmer
	var ok bool

	v, ok = g.(S1)
	fmt.Printf("value: %v, ok: %t\n", v, ok)

	g = S2{}

	v, ok = g.(S1)
	fmt.Printf("value: %v, ok: %t\n", v, ok)
}

type S1 struct{}

func (s S1) Gunma() string {
	return "S1 is Gunma"
}

type S2 struct{}

func (s S2) Gunma() string {
	return "S2 is Gunma"
}
```

上のコードはもちろん動かせます。

`Gunma()` を実装していない型との型アサーションはコンパイラレベルで弾かれます。
例えば、上のコードを少し改造して

```go
func main() {
	var g Gunmer

	g = S1{}

	var v Gunmer
	var ok bool

	v, ok = g.(string)
	fmt.Printf("value: %v, ok: %t\n", v, ok)
}
```

とした場合、そもそもコンパイルが通らなくなります。

型スイッチ構文
----

[スイッチ構文](https://golang.org/ref/spec#Switch_statements) の一環で型アサーションを用いることができます。


```go
switch x.(type) {
  case T:
    // x が T 型だった時に来るコード
  case S:
    // x が S 型だった時に来るコード
  default:
    // どの型にも当てはまらなかった時に来るコード
}
```

Interface の使い所
====

Go 言語での Interface の使い方は Java のそれとは少し違います。

Java においては、まず `interface` を定義し、その後 `interface` の仕様を満たすクラスを定義し、
さらに `interface` の仕様を満たすメソッドを実装して行きました。

例えば、 `Auth interface` を下記のように定義し

```java:Auth.java
inteface Auth {
  public User getCurrentUser();
}
```




Java では、例えば以下のようなコードがあり、ロジックを入れ替え可能にしたい場合
interface を使わなければかなり困難でした。

```
public class Auth {
  public boolean canAction() {
  }
}
```

```
go 側のサンプルは？
IO.read() にする。
```


Go 言語では Java とは逆のアプローチを取り、 `interface` を満たす型を実装する代わりに
`interface` を満たすオブジェクトを受け入れるメソッドを定義します。


interface がいつ使われるのかといえば、よく使われるのはライブラリの内側です。

もちろん、これはオープンソースや公開されたライブラリという意味ではなく、あなたの作っているプログラムの中で、
他のパッケージなどに公開しない部分も意味しています。

[](https://medium.com/@cep21/what-accept-interfaces-return-structs-means-in-go-2fe879e25ee8)



出典

公式ドキュメントは [こちら](https://golang.org/ref/spec#Interface_types) です。
なお、この章で述べている内容は [A Tour of Go](https://go-tour-jp.appspot.com/list) の
[Interfaces](https://go-tour-jp.appspot.com/methods/9) から
[Type switches](https://go-tour-jp.appspot.com/methods/16)
https://qiita.com/weloan/items/de3b1bcabd329ec61709
