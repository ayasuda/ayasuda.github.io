---
title: '2017年末の Rails プロジェクトは、多分これが一番楽だと思います'
description: ''
keywords:
  - rails
  - docker
---

# やっぱり Docker で動かしたい。そしてセットアップは `./bin/setup` で終わらせたい

2017年もくれるわけですから、やっぱり環境は Docker でやりたいものです。
何しろ、取り回しが楽ですし。

とはいえ、`docker-compose` や `bundle exec` を間違えずに打ち込むのは *面倒* です。

```
$ docker-compose run --rm rails bundle exec rails generate model user name:string
```

こんなコマンド、覚えられませんよ。

さて、そんなわけで Rails には `bin` ディレクトリがあるわけですし、この中のファイルを書き換えればよいでしょう。
