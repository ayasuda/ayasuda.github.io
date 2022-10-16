---
title: 'Blog template'
draft: true
description: ''
keywords:
  - Golang
  - Maven
---

`git` コマンドの `--since` や `--until` などには大雑把な日付指定ができます。
例えば、 `git log --since="1 week ago"` のような日付指定ができます。

この記事ではこれを自分のツールに実装する方法を記して行きます。

# 結論

自前実装のパターンとしてはこんな感じでどうでしょう？

```golang
```

# approxidate

git では `approxidate` と呼ばれるパーサが実装されています。
https://github.com/git/git/blob/v2.22.1/cache.h#L1550
https://github.com/git/git/blob/v2.22.1/date.c#L1254

go 移植
https://github.com/simplereach/timeutils

python の `approxidate` は git の実装を移植したものになります。
https://pypi.org/project/approxidate

ruby では `chronic` が有名です。実装は独自に行われています。
https://rubygems.org/gems/chronic

# 参考

https://alexpeattie.com/blog/working-with-dates-in-git
