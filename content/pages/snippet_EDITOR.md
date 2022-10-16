---
title: 'EDITOR, VISUAL を使ったプログラムの書き方'
draft: true
description: '環境変数 $EDITOR, $VISUAL が設定されている時、設定されたエディタでファイルを編集できるプログラムの作り方'
tags:
  - TODO
keywords:
  - TODO
---

簡単にやりたいなら普通に子プロセスでエディタ起動すれば良い。

git
  editor をセットしているのは editor.c:char * editor
  commit では launch_editor を起動している。
  launch_editor は editor.c にあり、エディタの軌道をしている
chef
crontab -e

https://itchyny.hatenablog.com/entry/2020/01/10/100000

