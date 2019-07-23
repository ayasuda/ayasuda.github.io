---
title: 'Golang time.Parse の使い方'
date: '2019-07-23'
description: 'Go 言語で文字列を`Time` 構造体に変換する `time.Parse` の使い方をまとめました'
keywords:
  - golang
  - time
---

この記事では、Golang で文字列を `Time` 構造体に変換する [`time.Parse`](https://golang.org/pkg/time/#Parse) の使い方を解説しつつ
使用例のコード片を提示します。

# 基本的な使い方

第１引数に、時刻のフォーマット定義を指定し、第２引数にパースしたい文字列を指定します。

フォーマットは、*必ず  2006年1月2日午後3時4分5秒(山岳部標準時)* である必要があります。
なんでこの時間？　と、一瞬思いますが、月日時分秒年の順番で表記した時、左から 1,2,3,4,5,6,7 と増えていきます。

山岳部標準時は `-7` です。

時刻を24時間表記でパースさせたい場合は、`15` を指定します。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// パースする対象である時間がどのように参照されているかのフォーマット定義です
	layout := "Jan 2, 2006 at 3:04pm (MST)"

	// パースする対象の文字列です
	value := "Feb 3, 2013 at 7:54pm (PST)"
	t, _ := time.Parse(layout, value)

	fmt.Println(t)
	// 2013-02-03 19:54:00 +0000 PST
}
```
https://play.golang.org/p/Y5yLTbfcULl

## 一部の定義を省略する

フォーマット定義およびパースしたい文字列から一部の値を外した場合、デフォルトとして 0 が、 0 が設定できない場合 1 が設定されます。
タイムゾーンの場合は UTC が設定されます。

下記の例では、時刻やタイムゾーンを省略したため、時・分・秒に 0 が、タイムゾーンに UTC がセットされます。
年を省略した場合は 0 が、月・日を省略した場合は、 1 がセットされます。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  layout := "2006-01-02"

  value := "2019-07-23"
  t, e := time.Parse(layout, value)

  if e != nil {
    fmt.Println(e)
  }

  fmt.Println(t)
  // 2019-07-23 00:00:00 +0000 UTC
}
```
https://play.golang.org/p/twodyyYITV6

つまり、何もかも省略した場合は、`0000-01-01 00:00:00 +0000` UTC になります。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  layout := ""

  value := ""
  t, e := time.Parse(layout, value)

  if e != nil {
    fmt.Println(e)
  }

  fmt.Println(t)
  // 0000-01-01 00:00:00 +0000 UTC
}
```
https://play.golang.org/p/1xG2G0FNSd1


## format と layout のフォーマットが違うとエラーになります。

例えば、下記の例を見てみましょう。

フォーマット定義ではタイムゾーン指定を削りましたが、パースしたい文字列ではタイムゾーンが指定されています。なので、エラーになります。。
この場合、パースすると必ず `0001-01-01 00:00:00 +0000 UTC` になります。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  layout := "Jan 2, 2006 at 3:04pm"
  value := "Feb 3, 2013 at 7:54pm (PST)"
  t, _ := time.Parse(layout, value)

  if e != nil {
    fmt.Println(e)
    // parsing time "Oct 3, 1986 at 8:07am (PST)": extra text:  (PST)
  }

  fmt.Println(t)
  // 0001-01-01 00:00:00 +0000 UTC
}
```
https://play.golang.org/p/JOeniv_Y0Wv

## フォーマットに日本語を使う

フォーマットに使用する日時さえあってれば可能です。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  layout := "2006年01月02日 15時04分05秒 (MST)"

  value := "2019年07月23日 20時10分11秒 (JST)"
  t, e := time.Parse(layout, value)

  if e != nil {
    fmt.Println(e)
  }

  fmt.Println(t)
  // 2019-07-23 20:10:11 +0000 JST
}
```
https://play.golang.org/p/dlwONJnLH8i

# 組み込みフォーマット

[timeパッケージの定数](https://golang.org/pkg/time/#pkg-constants) に定義されています。

```go
const (
        ANSIC       = "Mon Jan _2 15:04:05 2006"
        UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
        RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
        RFC822      = "02 Jan 06 15:04 MST"
        RFC822Z     = "02 Jan 06 15:04 -0700" // RFC822 with numeric zone
        RFC850      = "Monday, 02-Jan-06 15:04:05 MST"
        RFC1123     = "Mon, 02 Jan 2006 15:04:05 MST"
        RFC1123Z    = "Mon, 02 Jan 2006 15:04:05 -0700" // RFC1123 with numeric zone
        RFC3339     = "2006-01-02T15:04:05Z07:00"
        RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
        Kitchen     = "3:04PM"
        // Handy time stamps.
        Stamp      = "Jan _2 15:04:05"
        StampMilli = "Jan _2 15:04:05.000"
        StampMicro = "Jan _2 15:04:05.000000"
        StampNano  = "Jan _2 15:04:05.000000000"
)
```

# 存在しない時間を指定するとエラーになる

もちろん、エラーになります。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  layout := "2006年01月02日 15時04分05秒 (MST)"

  // 例えば、25時という存在しない時間にすると・・・
  value := "2019年07月23日 25時10分11秒 (JST)"
  t, e := time.Parse(layout, value)

  if e != nil {
  // 下記のように時間が0-23の範囲外であるというエラーが出てきます。
    fmt.Println(e)
    // parsing time "2019年07月23日 25時10分11秒 (JST)": hour out of range
  }

  fmt.Println(t)
  // 0001-01-01 00:00:00 +0000 UTC
}
```
https://play.golang.org/p/rhndc5_U4he

# タイムゾーンを省略したけど、日本時間にしたい - `time.ParseInLocation` で指定したタイムゾーンとみなしてパースする

例えば、日本国内のみで使うなら、タイムゾーンをいちいち設定するのは大変面倒だと思います。

`time.Parse` では、フォーマット定義（とパースしたい文字列）でタイムゾーンが指定されていない場合 `UTC` と判断していましたが、
`time.ParseInLocatoin` では、指定したタイムゾーンと見做すことができます。

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  loc, _ := time.LoadLocation("Asia/Tokyo")

  // time.ParseInLocation は、フォーマット定義でタイムゾーンが指定されていない場合
  // loc で指定されたタイムゾーンとしてパースします 
  layout := "Jan 2, 2006 at 3:04pm"
  value := "Jul 3, 2019 at 8:07pm"
  t, e := time.ParseInLocation(layout, value, loc)

  if e != nil {
    fmt.Println(e)
  }

  // 上記の場合、 loc が日本なので、 JST とみなします
  fmt.Println(t)
  // 2019-07-03 20:07:00 +0900 JST



  // time.Pasere の場合は UTC とみなします
  layout = "Jan 2, 2006 at 3:04pm"
  value = "Jul 3, 2019 at 8:07pm"
  t, e = time.Parse(layout, value)

  if e != nil {
    fmt.Println(e)
  }

  fmt.Println(t)
  // 2019-07-03 20:07:00 +0000 UTC



  // フォーマット定義にタイムゾーンが指定されている場合には、指定されたタイムゾーン通りにパースします
  layout = "Jan 2, 2006 at 3:04pm (MST)"
  value = "Jul 3, 2019 at 8:07pm (PST)"
  t, e = time.ParseInLocation(layout, value, loc)

  if e != nil {
    fmt.Println(e)
  }

  fmt.Println(t)
  // 2019-07-03 20:07:00 +0000 PST
}
```
https://play.golang.org/p/ltbXZvzGWTN
