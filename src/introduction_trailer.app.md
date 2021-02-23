---
title: 'はじめての Trailer.app'
date: '2019-12-09'
description: 'Github の様々な通知をよりよく受け取れるツールである　Trailer.app の紹介とオススメの設定についての紹介記事'
keywords:
  - Trailer
  - Github
  - Tools
---

あまりにも Github の通知に気付きづらいので、[Trailer.app](http://ptsochantaris.github.io/trailer/) を導入しようと思いました。

> Never miss a comment again. Track pull requests and issues across repositories, directly in your Notification Center or on any device.

なお、このドキュメントで使っている各種スクリーンショットなどは 2019 年 12 月 9 日のものとなっております。

はじめての Trailer.app
====

ざっくりいうと、Github への新しい　Purll-Request やコメント、など、様々なイベントの通知をわかりやすく提示してくれる
デスクトップへの常駐アプリで、
[macOS](http://ptsochantaris.github.io/trailer/)
[iOSアプリ](https://itunes.apple.com/app/id806104975?mt=8)
[Androidアプリ](https://github.com/amencarini/droidtrailer)
[Linux コマンドラインアプリ](https://github.com/ptsochantaris/trailer-cli)
版があります。

TODO:SS

## インストール方法

[Trailer.app](http://ptsochantaris.github.io/trailer/) (公式サイト) 行って、zip ダウンロードしてください。

zip を展開してアプリケーションディレクトリに突っ込んで、起動する

起動すると、macOS のメニューにアイコンが表示されます。

TODO:SS

アイコンをクリックすると、 (何も設定していないので) 警告が出てきます。

TODO:SS

> You have no repositories in your watchlist, or they are all currently marked as hidden.
> (ウォッチリストにリポジトリが存在しないか、全て「隠す」に設定されています。)
> You can change their status from the repositories section in your setting.
> (設定の「リポジトリ」セクションで設定を変更できます。)

セヤナ。

左上の

TODO:SS

をクリックすると、メニューが開き、「Prferences...」をクリックすると設定画面が開きます。

## 各種設定

### サーバ設定

設定画面はこんな感じです。

TODO:SS

本家 GitHub だけではなく、 *GitHub Enterprise にも同時に* 対応できます。

Access トークンは、本家なら [Setting - Developer settings - Personal access tokens](https://github.com/settings/tokens) から取得可能です。

TODO:SS サファリの Personal access tokens 画面

正しく設定ができたら、左下の Test ボタンで設定の確認をしましょう。

TODO:SS preferences, server view - with "Arrow to test button"

うまく設定できてれば、こんなポップアップが表示されます。

### リポジトリ設定

リポジトリ設定画面では、リポジトリごとに、Trailer.app で見られるようにするかを設定できます。

TODO:SS

ここで表示されるリポジトリは、Github または、Github Enterprise で watch しているリポジトリのみです。

TODO:SS

自分が watch しているリポジトリ一覧は、本家 Github なら [ここ](https://github.com/watching) からいけます。

### 表示設定

### ヒストリー設定

### コメント設定

### レビュー設定

### リアクション設定

### ステータス設定

### スヌーズ設定

### キーボード設定

### その他の設定
