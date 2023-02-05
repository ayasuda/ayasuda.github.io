---
title: 'Blog template'
draft: true
description: ''
keywords:
  - Java
  - Maven
---

go 言語での文字列の取扱いについて見ていきましょう。

見出し１
====


文字列の長さを得る
n 番目の文字を得る
文字列を結合する

文字列を複製する
文字列を反転させる
文字列を分割する
文字列を比較する
文字列を検索する
文字列をn文字ごとに処理する
文字列を変換する
文字列をフォーマットする
文字列の前後から空白を取り除く
文字列を置換する

正規表現にマッチするか
正規表現で置換する


各種文字列の操作
====


文字列を初期化する
----

```
package main

import "fmt"

func main () {
  var s1 string
  s1 = "foo"
  s2 := "bar"

  fmt.Println(s1) // "foo"
  fmt.Println(s2) // "bar"
}
```


文字列の長さを得る
----

```
package main

import "fmt"


func main() {
  sample = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

  l := len(sample)

  fmt.Println(l)
}
```

文字列から文字を切り出す (1文字)
----

```
package main

import "fmt"


func main() {
  sample = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

  c := sample[47]

  fmt.Println(c)
}
```

オーバーしたら？

rune と byte
