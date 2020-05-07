---
title: 'Go でコマンドラインツールを作るときのテンプレ ayasuda 版'
date: '2120-12-31'
description: ''
tags:
  - Go
  - Tools
  - Tips
keywords:
  - Go
  - Golang
  - Command Line Tool
  - コマンドラインツール
  - Boiler plate
  - ボイラープレート
---

この記事では、Golang でコマンドラインツールを作るときの最初のディレクトリ構成およびファイルの内容について書く。

なお、結論から言うと個人の自由なので、あくまでも、私個人の場合を記している。

# 結論

基本的には https://junkyard.song.mu/slides/gocon2019-fukuoka 流

コマンド `foo` を作る場合

以下のファイルを作る

* README.md
* foo.go
* foo/cmd/main.go
* go.mod
* go.sum

README.md

好きに描いてください。
https://gist.github.com/PurpleBooth/109311bb0361f32d87a2
https://www.makeareadme.com/
https://qiita.com/KamataRyo/items/466255fc33da12274c72
https://help.github.com/ja/github/creating-cloning-and-archiving-repositories/about-readmes
https://deeeet.com/writing/2014/07/31/readme/

foo.go

コマンドラインアプリケーションとして `Run` を実装するファイル。
ネーミングは実のところなんでも良いが・・・ほかの開発者が最初に見やすいんじゃないかしら？
このネーミングで`foo` ディレクトリできるのか？　その名前のディレクトリはいるのか？　pakcage foo でしょ？ root

foo/cmd/main.go

コマンド本体
極力薄くする


go.mod, go.sum: 作り方を調べる　




* `foo/cmd/main.go` に `package main` を置く
 * main は薄く
 * os.Exit するのは main のみ
* 本体となる `package foo` は `foo/` 以下に書いて置く。
 * テストがしやすい
 * ライブラリとして再利用可能

デメリットは、 `go get ROOT` にはならない
cf. golang のデバッグツール delve は $ go get -u github.com/go-delve/delve/cmd/dlv でインストールする



cli ツールのFWとして
https://github.com/urfave/cli



後は参考資料読みながら、メリットとデメリットを書く。


https://deeeet.com/writing/2014/06/22/cli-init/

https://github.com/tcnksm/gcli


* コマンドラインツールボイラープレート
* プロセス起動とシグナル制御・デーモン化
* ロギングとログファイル
* 設定ファイルの読み込み
* サブコマンドおよびフラグ

ここまでできれば簡単なサーバは書き始められるはず。
次にやるのは認証サーバとして必要な機能群
