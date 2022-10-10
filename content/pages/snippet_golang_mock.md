---
title: 'Blog template'
draft: true
description: ''
keywords:
  - Java
  - Maven
---

Go 言語とスタブ・モック

なぜ
====

発生する問題点
---

パッケージ間で依存するプログラムコードがある時、単体テストが書きにくいことがある

例えば、以下のようなプログラムがあるとする

main -> A -> B というような依存関係がある。

この時、A の単体テストをしたい

```
package main

func main() {
  fmt.Println(foo.AddFoo("this is main"))
}

```


```
package foo

func AddFoo(s string) string {
  return bar.AddBar("it is foo" + s)
}
```

```
package bar

func AddBar(s string) string {
  return "it is bar" + s
}
```

この時、bar.AddBar のテストを書くのは簡単
しかし、foo.AddFoo は bar.AddBar の実装に依存しているので、テストが簡単に書けない
-> 単体テストなので、 foo パッケージのみをテストしたい

foo.AddFoo のテスト中で、 bar.AddBar を代替にしたい


スタブとモック
---

今度、
https://martinfowler.com/articles/mocksArentStubs.html
を読む。

### スタブ

依存しているものの代替となる部品です
代替するので決まった値を返します。

### モック

インターフェースの検証用で、メソッド呼び出しとかを記録する


